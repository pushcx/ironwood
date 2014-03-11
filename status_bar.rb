
module Ironwood

class StatusBar
  attr_reader :game
  
  def initialize game
    @game = game
  end

  def noise_count
    # [:move, :rest, :move] is 1, not 2
    game.player.last_actions.reverse.inject(0) { |c, a| return c if a != :move; c + 1 }
  end

  def view game
    noise = %w{. _ - !}[noise_count]
    "Player | Noise: #{noise} | Time #{game.time.tick} | x/y debug (#{game.player.x}, #{game.player.y})"
  end

  def style_map
    style_map = Dispel::StyleMap.new(1)
    style_map.add(['#dddddd', '#222334'], 0, 0..80)
    style_map.add(['#000000', '#ff0000'], 0, [16]) if game.player.noisy?
    style_map
  end
end

end # Ironwood
