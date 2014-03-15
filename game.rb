module Ironwood

class Game
  attr_accessor :status_bar, :map, :time, :player, :map_display
  attr_reader :game_over, :score

  def initialize(screen_width, screen_height)
    @status_bar = StatusBar.new(self)
    @time = GameTime.new
    @game_over = false

    @map = GenMap.new(time)
    @player = Player.new map, $X, $Y, DIR_E
    @map_display = MapDisplay.new(map, screen_width, screen_height - 1)
    @score = Score.new time
  end

  def turn
    # player's turn happens implicitly in demo - should prob move here
    map.turn

    # player has moved onto mob to knock it out
    if mob = map.mobs.mob_at_player
      return @game_over = true if mob.hunting? # can't knock out alert guards
      score.guard
      map.mobs.delete mob
      map.drop_item Body.new(map, mob.x, mob.y)
    end

    # player has moved onto treasure to pick it up
    if item = map.items.item_at(player.x, player.y) and item.is_a? Treasure
      score.treasure
      map.items.delete item
    end

    map.mobs.enemies.each do |mob|
      mob.decide_state(player)
      #d " - chose #{mob.state}, dest #{mob.dest_x},#{mob.dest_y}"
      mob.turn
      #d " - finished at #{mob.x},#{mob.y}"

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
