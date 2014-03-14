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
    @sounds = {}
    @items = Items.new

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
      end
    end

    # trim off unused rows
    empty_row = '#' * @width
    @tiles.shift while @tiles[1] == empty_row
    @tiles.pop while @tiles[-2] == empty_row
    before_height = @height
    @height = @tiles.length
    taken_y = @height - before_height

    leftmost = @rooms.map(&:left).min
    rightmost = @rooms.map(&:right).max
    @tiles.each_with_index do |row, i|
      @tiles[i] = row.slice(leftmost-1, rightmost - leftmost + 3)
    end
    before_width = @width
    @width = @tiles.first.length
    taken_x = @width - before_width

    # update room coords for mob gen
    @rooms.each_with_index do |room, i|
      @rooms[i] = Room.new(
        room.top - taken_y,
        room.bottom - taken_y,
        room.left - taken_x,
        room.right - taken_y
      )
    end

    d_map

    x, y = 0, 0
    while @tiles[y][x] != '.' do
      x, y = [rand(0..@width-1), rand(0..@height-1)]
    end
    $X, $Y = x, y # terrible hack to make sure player is in bounds
  end

  def d_map
    @tiles.each do |row|
      d row
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

