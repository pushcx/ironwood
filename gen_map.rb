require_relative 'map'

module Ironwood

MIN_DIM = 2
MAX_DIM = 9
ROOM_DISTANCES = [1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,4,4,5]

Room = Struct.new :top, :bottom, :left, :right

class GenMap < Map
  def initialize time
    super(time)
    generate
  end

  def generate
    @mobs = Mobs.new
    @items = Items.new
    @sounds = {}

    @rooms = []
    @width, @height = rand(20..500), rand(20..400)
    @tiles = Array.new(@height) { '#' * @width }
    #d "width #{width} height #{height}"

    top    = rand(1..@height-MIN_DIM-2)
    bottom = top + rand(MIN_DIM..[MAX_DIM, @height - top - 2].min)
    left   = rand(1..@width-MIN_DIM-2)
    right  = left + rand(MIN_DIM..[MAX_DIM, @width - left - 2].min)

    dig_room top, bottom, left, right

    rand(60..600).times.each do |i|
      from = @rooms.sample
      case rand(4)
      when 0 # top
        bottom = from.top - ROOM_DISTANCES.sample
        next if bottom - MIN_DIM <= 0
        height = rand(MIN_DIM..[MAX_DIM, bottom - 1].min)
        top = bottom - height

        width = rand(MIN_DIM..MAX_DIM)
        left = rand([1,from.left - width].max..[@width - width - 2,from.right].min)
        right = left + width

        dig_room top, bottom, left, right
        x = rand([left, from.left].max..[right, from.right].min)
        (bottom..from.top).each do |y|
          @tiles[y][x] = '.'
        end
        if from.top - bottom == 2 and @tiles[bottom+1][x - 1] == '#' and @tiles[bottom+1][x + 1] == '#'
          @tiles[bottom + 1][x] = '+'
        end
      when 1 # bottom
        top = from.bottom + ROOM_DISTANCES.sample
        height = rand(MIN_DIM..MAX_DIM)
        bottom = top + height
        next if bottom >= @height - 1

        width = rand(MIN_DIM..MAX_DIM)
        left = rand([1,from.left - width].max..[@width - width - 2,from.right].min)
        right = left + width

        dig_room top, bottom, left, right
        x = rand([left, from.left].max..[right, from.right].min)
        (from.bottom..top).each do |y|
          @tiles[y][x] = '.'
        end
        if top - from.bottom == 2 and @tiles[top-1][x - 1] == '#' and @tiles[top-1][x + 1] == '#'
          @tiles[top - 1][x] = '+'
        end
      when 2 # left
        right = from.left - ROOM_DISTANCES.sample
        width = rand(MIN_DIM..MAX_DIM)
        left = right - width
        next if left <= 0

        height = rand(MIN_DIM..MAX_DIM)
        top = rand([1,from.top - height].max..[@height - height - 2,from.bottom].min)
        bottom = top + height

        dig_room top, bottom, left, right
        y = rand([top, from.top].max..[bottom, from.bottom].min)
        (right..from.left).each do |x|
          @tiles[y][x] = '.'
        end
        if from.left - right == 2 and @tiles[y][right + 1] == '#' and @tiles[y][right + 1] == '#'
          @tiles[y][right + 1] = '+'
        end
      when 3 # right
        left = from.right + ROOM_DISTANCES.sample
        width = rand(MIN_DIM..MAX_DIM)
        right = left + width
        next if right >= @width - 1

        height = rand(MIN_DIM..MAX_DIM)
        top = rand([1,from.top - height].max..[@height - height - 2,from.bottom].min)
        bottom = top + height

        dig_room top, bottom, left, right
        y = rand([top, from.top].max..[bottom, from.bottom].min)
        (from.right..left).each do |x|
          @tiles[y][x] = '.'
        end
        if left - from.right == 2 and @tiles[y][left - 1] == '#' and @tiles[y][left - 1] == '#'
          @tiles[y][left - 1] = '+'
        end
      end
    end

    # trim off unused rows
    empty_row = '#' * @width
    @tiles.shift while @tiles[1] == empty_row
    taken_y = @height - @tiles.length
    @tiles.pop while @tiles[-2] == empty_row
    @height = @tiles.length

    leftmost = @rooms.map(&:left).min
    taken_x = leftmost - 1
    rightmost = @rooms.map(&:right).max
    @tiles.each_with_index do |row, i|
      @tiles[i] = row.slice(leftmost-1, rightmost - leftmost + 3)
    end
    @width = @tiles.first.length

    # update room coords for mob gen
    # this is beeroken
    #@rooms.each_with_index do |room, i|
    #  r = Room.new(
    #    room.top - taken_y,
    #    room.bottom - taken_y,
    #    room.left - taken_x,
    #    room.right - taken_y
    #  )
    #  @rooms[i] = r
    #end

    x, y = 0
    x, y = rand(0..@width-1),rand(0..@height-1) until available?(x,y)
    drop_item Staircase.new(self, x, y)

    # drop treasure
    #d "#{@width}x#{@height}"
    #d_map
    rand(60..90).times do
      x, y = rand(0..@width-1),rand(0..@height-1)
      next unless available?(x, y)
      drop_item Treasure.new(self, x, y)

      # drop guard near most treasures
      next if rand(3) == 0
      add_guard_guarding(x, y)
    end
    #d_map

    rand(50..150).times do
      x, y = rand(0..@width-1), rand(0..@height-1)
      next unless available?(x, y)
      #d "random at #{x},#{y} #{@tiles[y][x]}"
      mobs << Guard.new(self, x, y, rand(0..7))
    end

    # add guards guarding guards :)
    rand(3..8).times do
      mob = mobs.sample
      add_guard_guarding mob.x, mob.y
    end

    # make some guards patrol
    x = y = 0
    rand(1..5).times do |mob|
      mob = mobs.sample
      radius = 30
      x, y = rand((mob.x-radius)..(mob.x+radius)), rand((mob.y-radius)..(mob.y+radius)) until available?(x, y)
      mob.order_patrol_to x, y
      #d "#{mob.object_id} should patrol from #{mob.x},#{mob.y} to #{x},#{y}"
    end

    #d_map

    #d 'put player in bounds'
    x, y = 0, 0
    x, y = [rand(0..@width-1), rand(0..@height-1)] while !available?(x,y)
    $X, $Y = x, y # terrible hack to make sure player is in bounds

    #d_map

    # remove any mobs near the player to give breathing room
    ([0, (y - 8)].max..[@width - 1,(y + 8)].min).each do |y|
      ([0, (x - 8)].max..[@width - 1,(x + 8)].min).each do |x|
        next unless mob = mobs.mob_at(x, y)
        mobs.delete mob
      end
    end
    #d 'done'
  end

  def add_guard_guarding(guard_x, guard_y)
    #d "add_guard_guarding(#{guard_x},#{guard_y})"
    x, y = 0,0
    x, y = guard_x + rand(-5..5), guard_y + rand(-5..5) while !available?(x,y)
    #d "chose #{x},#{y} #{@tiles[y][x]}"
    guard = Guard.new(self, x, y, 0)
    guard.direction = guard.direction_to(guard_x, guard_y)
    mobs << guard
  end

  def available? x, y
    in_bounds(x, y) and @tiles[y][x] == '.' and !mobs.mob_at(x,y) and !items.item_at(x,y)
  end

  def d_map
    @tiles.each_with_index do |row, y|
      row.split('').each_with_index do |tile, x|
        if items.item_at? x, y
          $DEBUG.print '$'
        elsif mobs.mob_at? x, y
          if tile == '#'
            $DEBUG.print '^'
          else
            $DEBUG.print 'G'
          end

        else
          $DEBUG.print tile
        end
      end
      $DEBUG.puts
    end
  end

  def dig_room top, bottom, left, right
    (left..right).each do |x|
      (top..bottom).each do |y|
        return if @tiles[y][x] != '#'
      end
    end
    (left..right).each do |x|
      (top..bottom).each do |y|
        @tiles[y][x] = '.'
      end
    end
    @rooms << Room.new(top, bottom, left, right)
  end
end

end # Ironwood

