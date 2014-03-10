module Ironwood

class Game
  attr_accessor :status_bar, :map, :time, :player, :fov, :map_display, :mobs

  def initialize(map, screen_width, screen_height)
    @status_bar = StatusBar.new(self)
    @map = map
    @time = GameTime.new
    @player = Player.new 3, 12, DIR_N
    @map_memory = MapMemory.new(map)
    @fov = map.fov_for_player(player)
    @map_display = MapDisplay.new(map, fov, screen_width, screen_height - 1)

    @mobs = Mobs.new([
      @player,
      StandingGuard.new(5, 5, DIR_W)
    ])
  end

  def display
    fov.move(player.x, player.y, player.direction)
    map_display.mobs = mobs
    [view, style_map, [0,0]]
  end

  def view
    [
      status_bar.view(self),
      map_display.view,
      #messages.view,
    ].join("\n")
  end

  def style_map
    status_bar.style_map + map_display.style_map
  end
end

end # Ironwood
