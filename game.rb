module Ironwood

class Game
  attr_accessor :map, :player, :fov

  def initialize(map)
    @map = map
    @player = Player.new 3, 12, 0
    @fov = map.fov_for_player(player)
  end

  def display
    fov.move(player.x, player.y, player.direction)
    [view, style_map, [0,0]]
  end

  def view
    [
      player.view,
      map.view(fov),
      #messages.view,
    ].join("\n")
  end

  def style_map
    player.style_map() + map.style_map(fov)
  end
end

end # Ironwood
