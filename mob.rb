module Ironwood

class Mob
  attr_accessor :x, :y, :direction, :fov

  def initialize map, x, y, direction
    @x = x
    @y = y
    @direction = direction
    @fov = Visibility::FieldOfView.new(map, x, y, direction)
  end

  def player? ; false ; end
  def tile ; '‽' ; end
  def color ; '#ff0000' ; end
end

end # Ironwood
