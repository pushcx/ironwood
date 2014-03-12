
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
    @x, @y = mob.x, mob.y
    @radius = RADIUSES[type]
    @priority = PRIORITIES[type]
  end

  def heard_at? x, y
    [ (@x - x).abs, (@y - y).abs ].max < radius
  end
end

end # Ironwood
