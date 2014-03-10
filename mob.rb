require_relative 'movement'

module Ironwood

class Mob
  include Movement

  attr_accessor :map, :x, :y, :direction, :fov

  def initialize map, x, y, direction
    @map = map
    @x = x
    @y = y
    @direction = direction
    @fov = Visibility::FieldOfView.new(map, x, y, direction)
  end

  def player? ; false ; end
  def tile ; '‽' ; end
  def color ; '#800080' ; end
end

end # Ironwood
