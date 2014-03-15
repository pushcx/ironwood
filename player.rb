require_relative 'mob'

module Ironwood

class Player < Mob
  attr_reader :floor, :smokebombs

  def initialize map, x, y, direction
    super
    @smokebombs = 2
    on_new_map(map, x, y, direction)
  end

  def on_new_map map, x, y, direction
    #d "on_new_map map #{x},#{y} #{direction}"
    @smokebombs += 1
    @map = map
    map.mobs << self
    @x = x
    @y = y
    @direction = direction
    @fov = Visibility::FieldOfView.new(map, x, y, direction, Visibility::ShadowCasting, PLAYER_VIEW_RADIUS)
  end

  def player? ; true ; end
  def tile ; '@' ; end
  def color ; '#9999ff' ; end
end

end # Ironwood
