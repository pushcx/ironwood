module Ironwood

class MapMemory
  attr_reader :map, :tiles

  def initialize map
    @map = map
    @tiles = []
    (0..map.height-1).each do |y|
      @tiles << '?' * map.width
    end
  end

  def add fov
    (0..@map.height-1).each do |y|
      (0..@map.width-1).each do |x|
        @tiles[y][x] = map.tile(x, y) if fov.visible?(x, y)
      end
    end
  end

  def remember? x, y
    raise IndexError, "x #{x} out of range" unless (0..@map.width-1).include? x
    raise IndexError, "y #{y} out of range" unless (0..@map.height-1).include? y
    @tiles[y][x] != '?'
  end

  def tile x, y
    @tiles[y][x]
  end

end

end # Ironwood
