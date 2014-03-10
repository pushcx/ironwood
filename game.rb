module Ironwood

class Game
  attr_accessor :map, :player, :fov, :map_display

  def initialize(map, screen_width, screen_height)
    @map = map
    @player = Player.new 3, 12, 0
    @map_memory = MapMemory.new(map)
    @fov = map.fov_for_player(player)
    @map_display = MapDisplay.new(map, fov, screen_width, screen_height - 1)
  end

  def display
    fov.move(player.x, player.y, player.direction)
    [view, style_map, [0,0]]
  end

  def view
    [
      player.view,
      map_display.view,
      #messages.view,
    ].join("\n")
  end

  def style_map
    player.style_map + map_display.style_map
  end
end

end # Ironwood
