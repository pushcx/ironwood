require_relative 'mob'

module Ironwood

class Player < Mob
  attr_reader :floor

  def initialize map, x, y, direction
    super
    @floor = 0
    on_new_map(map, x, y, direction)
  end

  def on_new_map map, x, y, direction
    #d "on_new_map map #{x},#{y} #{direction}"
    @map = map
    map.mobs << self
    @x = x
    @y = y
    @direction = direction
    @floor += 1
    @fov = Visibility::FieldOfView.new(map, x, y, direction, Visibility::ShadowCasting, PLAYER_VIEW_RADIUS)
  end

  def player? ; true ; end
  def tile ; '@' ; end
  def color ; '#9999ff' ; end
end

end # Ironwood
