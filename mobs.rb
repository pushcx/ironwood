
module Ironwood

class Mobs
  attr_reader :list

  def initialize list=[]
    @list = list
  end

  def enemies(&block)
    list.select { |m| !m.player? }.each(&block)
  end

  def each(&block)
    list.each(&block)
  end

  def delete mob
    list.delete mob
  end

  def player
    list.each do |mob|
      return mob if mob.player?
    end
    raise "Looked for player, didn't find"
  end

  def mob_at x, y
    enemies.each do |mob|
      return mob if mob.x == x and mob.y == y
    end
    nil
  end
  alias :mob_at? :mob_at

  def mob_at_player
    mob_at player.x, player.y
  end
  alias :mob_at_player? :mob_at_player

  def update_fovs!
    list.each do |mob|
      mob.fov.move(mob.x, mob.y, mob.direction)
    end
  end

end

end # Ironwood
