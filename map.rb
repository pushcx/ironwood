require_relative 'visibility'

module Ironwood

# Basic map storage.
class StringMap
  attr_reader :width, :height
  attr_accessor :mobs

  # Takes an array of strings: . is ground and # is wall. Assumes rectilinearity.
  # This will be elaborated upon greatly in the future, and probably use NArray.
  def initialize(string_array)
    @tiles = string_array
    @width, @height = string_array.first.length, string_array.length
    @mobs = nil
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
end

end
