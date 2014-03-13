module Ironwood

class Item
  attr_reader :map
  attr_accessor :x, :y

  def initialize map, x, y
    @map, @x, @y = map, x, y
  end

  def tile ; '*' ; end
  def color ; '#ffffff' ; end
end

end # Ironwood

