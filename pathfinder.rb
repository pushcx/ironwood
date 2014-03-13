require_relative 'astar'

module Ironwood

class Pathfinder < Astar
  attr_reader :map

  def initialize map, from, to
    @map = map
    super(from, to)
  end

  def heuristic from, to
    [ (from.x - to.x).abs, (from.y - to.y).abs ].max
  end

  # constant cost, octagonal or diagonal
  def cost(from, to)
    1
  end

  def passable? x, y
    !map.blocks_movement?(x, y)
  end

  def expand at
    x, y = at.x, at.y

    [
      [x,     y - 1], # n
      [x + 1, y    ], # east
      [x,     y + 1], # south
      [x - 1, y    ], # west
      [x + 1, y - 1], # ne
      [x + 1, y + 1], # se
      [x - 1, y + 1], # sw
      [x - 1, y - 1], # nw
    ]
  end
end

end # Ironwood
