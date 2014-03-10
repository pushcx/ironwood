
module Ironwood

class StatusBar
  attr_reader :game
  
  def initialize game
    @game = game
  end

  def view game
    "Player (#{game.player.x}, #{game.player.y}) | Time #{game.time.tick}"
  end

  def style_map
    style_map = Dispel::StyleMap.new(1)
    style_map.add(['#dddddd', '#222334'], 0, 0..80)
    style_map
  end
end

end # Ironwood
