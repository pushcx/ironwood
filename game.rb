module Ironwood

class Game
  attr_accessor :status_bar, :map, :time, :player, :map_display
  attr_reader :game_over

  def initialize(map_string, screen_width, screen_height)
    @status_bar = StatusBar.new(self)
    @time = GameTime.new
    @game_over = false

    @map = StringMap.new(map_string)
    @map_memory = MapMemory.new(map)
    @player = Player.new map, 4, 12, DIR_N
    @map.mobs = Mobs.new([ # ew circular referencing
      @player,
      #StandingGuard.new(map, 5, 5, DIR_W),
      StandingGuard.new(map, 8, 3, DIR_E),
    ])
    @map_display = MapDisplay.new(map, screen_width, screen_height - 1)
  end

  def turn
    map.mobs.each do |mob|
      next if mob.player?
      mob.set_state(player)
      mob.turn

      @game_over = true if mob.x == player.x and mob.y == player.y
    end
    time.advance
  end

  def display
    map.mobs.update_fovs!
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
