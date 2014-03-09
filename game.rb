module Ironwood

class Game
  attr_accessor :map, :x, :y, :direction, :fov

  def initialize(map)
    @map = map
    @x, @y = 3, 12
    @direction = 0
    @fov = map.fov_for_player(x, y, direction)
  end

  def display
    fov.move(x, y, direction)
    [view, style_map, [0,0]]
  end

  def view
    [
      #player.view,
      map.view(fov),
      #messages.view,
    ].join("\n")
  end

  def style_map
    map.style_map(fov)
  end
end

end # Ironwood
