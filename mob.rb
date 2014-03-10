module Ironwood

class Mob
  attr_accessor :x, :y, :direction

  def initialize x, y, direction
    @x = x
    @y = y
    @direction = direction
  end

  def tile ; '‽' ; end
  def color ; '#ff0000' ; end
end

end # Ironwood
