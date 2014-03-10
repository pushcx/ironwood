module Ironwood

class Game
  attr_accessor :status_bar, :map, :time, :player, :map_display, :mobs

  def initialize(map, screen_width, screen_height)
    @status_bar = StatusBar.new(self)
    @map = map
    @time = GameTime.new
    @player = Player.new map, 3, 12, DIR_N
    @map_memory = MapMemory.new(map)

    @mobs = Mobs.new([
      @player,
      StandingGuard.new(map, 5, 5, DIR_W),
      #StandingGuard.new(map, 8, 5, DIR_E),
    ])
    @map_display = MapDisplay.new(map, mobs, screen_width, screen_height - 1)
  end

  def turn
    mobs.each do |mob|
      next if mob.player?
      mob.set_state(player)
      mob.turn(player)
    end
    time.advance
  end

  def display
    mobs.update_fovs!
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
