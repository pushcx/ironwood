
module Ironwood

class Mobs
  attr_reader :list

  def initialize list=[]
    @list = list
  end

  def player
    list.each do |mob|
      return mob if mob.is_a? Player
    end
    nil
  end

  def mob_at x, y
    list.each do |mob|
      return mob if mob.x == x and mob.y == y
    end
    nil
  end
  alias :mob_at? :mob_at

  def update_fovs!
    list.each do |mob|
      mob.fov.move(mob.x, mob.y, mob.direction)
    end
  end
end

end # Ironwood
