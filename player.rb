module Ironwood

class Player
  attr_accessor :x, :y, :direction

  def initialize x, y, direction
    @x = x
    @y = y
    @direction = direction
  end
end

end # Ironwood
