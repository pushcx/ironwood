module Ironwood

class Player
  attr_accessor :x, :y, :direction

  def initialize x, y, direction
    @x = x
    @y = y
    @direction = direction
  end

  def view
    "Player (#{x}, #{y})"
  end

  def style_map
    style_map = Dispel::StyleMap.new(1)
    style_map.add(['#dddddd', '#222334'], 0, 0..80)
    style_map
  end
end

end # Ironwood
