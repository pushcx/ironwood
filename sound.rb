
module Ironwood

class Sound
  RADIUSES = {
    run:  10,
    drag: 6,
    yell: 15,
  }

  PRIORITIES = {
    run:  2,
    drag: 1,
    yell: 3,
  }

  attr_reader :mob, :x, :y, :radius, :priority

  def initialize mob, type
    @mob = mob
    @x, @y = mob.x, mob.y
    @radius = RADIUSES[type]
    @priority = PRIORITIES[type]
  end

  def heard_by? listener
    # players see their own noises, but mobs don't
    return false if mob == listener and !listener.player?
    return false if listener.x == x and listener.y == y
    #d "heard_by? #{listener.tile}(#{listener.x},#{listener.y}) #{x},#{y} x #{radius}"
    [ (@x - listener.x).abs, (@y - listener.y).abs ].max < radius
  end
end

end # Ironwood
