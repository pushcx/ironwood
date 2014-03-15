
module Ironwood

class StatusBar
  attr_reader :game
  
  def initialize game
    @game = game
  end

  def view game
    "Smoke bombs: #{game.player.smokebombs.to_s.rjust(3)} | Noise: ._-^*! | #{game.score.statusline}"
  end

  def style_map
    style_map = Dispel::StyleMap.new(1)
    style_map.add(['#dddddd', '#222334'], 0, 0..80)
    style_map.add(['#000000', '#dddddd'], 0, 26..(26 + game.player.noise_count))
    style_map.add(['#000000', '#ff0000'], 0, 26..31) if game.player.noise_count >= 5
    style_map
  end
end

end # Ironwood
