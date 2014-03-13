module Ironwood

class Body
  attr_reader :map
  attr_accessor :x, :y

  def initialize map, x, y
    @map, @x, @y = map, x, y
  end

  def tile ; '%' ; end
  def color ; '#aa5500' ; end
end

end # Ironwood

