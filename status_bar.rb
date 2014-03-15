
module Ironwood

class StatusBar
  attr_reader :game
  
  def initialize game
    @game = game
  end

  def view game
    "Player | Noise: _-^! | #{game.score.statusline}"
  end

  def style_map
    style_map = Dispel::StyleMap.new(1)
    style_map.add(['#dddddd', '#222334'], 0, 0..80)
    style_map.add(['#000000', '#dddddd'], 0, [16 + game.player.noise_count])
    style_map.add(['#000000', '#ff0000'], 0, [19]) if game.player.noise_count >= 3
    style_map
  end
end

end # Ironwood
