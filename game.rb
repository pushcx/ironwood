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
    @player = Player.new map, 7, 3, DIR_E
    @map.mobs = Mobs.new([ # ew circular referencing
      @player,
      #StandingGuard.new(map, 5, 5, DIR_W),
      StandingGuard.new(map, 8, 3, DIR_E),
    ])
    @map.mobs.list.last.order_walk_to(30, 3)
    @map_display = MapDisplay.new(map, screen_width, screen_height - 1)
  end

  def turn
    # player has moved onto mob to knock it out
    if mob = map.mobs.mob_at_player
      return @game_over = true if mob.hunting? # can't knock out alert guards
      map.mobs.delete mob
    end

    map.mobs.enemies.each do |mob|
      mob.decide_state(player)
      mob.turn

      @game_over = true if map.mobs.mob_at_player?
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
