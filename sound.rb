
module Ironwood

class Sound
  RADIUSES = {
    run:  10,
    drag: 8,
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
    return false if mob == listener or (mob.x == x and mob.y == y)
    [ (@x - listener.x).abs, (@y - listener.y).abs ].max < radius
  end
end

end # Ironwood
