require_relative 'visibility'

module Ironwood

# Basic map storage.
class StringMap
  attr_reader :width, :height

  # Takes an array of strings: . is ground and # is wall. Assumes rectilinearity.
  # This will be elaborated upon greatly in the future, and probably use NArray.
  def initialize(string_array)
    @tiles = string_array
    @width, @height = string_array.first.length, string_array.length
  end

  # Returns the tile at coordinates x, y.
  # Tiles must eventually be their own objects.
  def tile(x, y)
    raise IndexError, "x #{x} out of range" unless (0..@width-1).include? x
    raise IndexError, "y #{y} out of range" unless (0..@height-1).include? y
    return @tiles[y][x].chr
  end

  def crop_tile(x, y)
    return ' '.chr unless (0..@width-1).include?(x) and (0..@height-1).include?(y)
    return @tiles[y][x].chr
  end

  # Should be a method on Tile.
  def blocks_visibility?(x, y)
    return (x < 0 or y < 0 or x >= @width or y >= @height or '#+'.include? tile(x, y))
  end
  
  # Should be a method on Tile.
  def blocks_movement?(x, y)
    return (x < 0 or y < 0 or x >= @width or y >= @height or '#~'.include? tile(x, y))
  end

  # who calls this? View class for interface?
  def fov_for_player player
    Visibility::FieldOfView.new(self, player.x, player.y, player.direction)
  end

  def crop x, y, width, height
    lines = []
    (y..(y + height - 1)).each do |y|
      row = ''
      (x..(x + width - 1)).each do |x|
        row << crop_tile(x, y)
      end
      lines << row
    end
    lines
  end

  def view fov
    str = @tiles.map { |s| s.clone }
    str[fov.actor_y][fov.actor_x] = '@'
    str
  end

  def style_map fov
    style_map = Dispel::StyleMap.new(@height)
    @height.times do |y|
      @width.times do |x|
        if x == fov.actor_x and y == fov.actor_y
          style_map.add(["#dddddd", "#000001"], y, [x])
        else
          if fov.visible?(x, y)
            style_map.add(["#ffffff", "#000000"], y, [x])
          else
            style_map.add(["#000000", "#000000"], y, [x])
          end
        end
      end
    end
    style_map
  end

  def display(screen, fov)
    #dark, lit = Ncurses.COLOR_PAIR(8), Ncurses.COLOR_PAIR(7) | Ncurses::A_BOLD
    dark, lit = 0, 0

    @width.times do |x|
      @height.times do |y|
        if x == fov.actor_x and y == fov.actor_y
          c = '@'
          attr = lit
        else
          # will need to change to ask tile its representation
          c = tile(x, y)
          attr = fov.visible?(x, y) ? lit : dark
        end
        screen.draw(c, [], [x,y])
        #screen.puts(c, :x => x, :y => y, :attrs => [attr])
      end
    end
    #screen.attrset(lit)

    # print light map below
    #screen.attrset(lit)
    #(0...@width).each do |x|
    #  (0...@height).each do |y|
    #    #ch = fov.visible?(x, y) ? '.' : '#'
    #    ch = fov.step x, y
    #    screen.mvaddstr(y + @height + 1, x, ch)
    #  end
    #end
    #screen.refresh()
  end
end

end
