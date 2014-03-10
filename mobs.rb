
module Ironwood

class Mobs
  attr_reader :list

  def initialize list=[]
    @list = list#Hash[ list.map { |m| [[m.x, m.y], m] } ]
  end

  def mob_at x, y
    list.each do |mob|
      return mob if mob.x == x and mob.y == y
    end
    nil
  end
  alias :mob_at? :mob_at
end

end # Ironwood
