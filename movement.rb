require_relative 'pathfinder'

module Ironwood

module Movement

  DELTAS = {
    DIR_N  =>  [  0, -1 ],
    DIR_NE =>  [  1, -1 ],
    DIR_E  =>  [  1,  0 ],
    DIR_SE =>  [  1,  1 ],
    DIR_S  =>  [  0,  1 ],
    DIR_SW =>  [ -1,  1 ],
    DIR_W  =>  [ -1,  0 ],
    DIR_NW =>  [ -1, -1 ],
  }

  def dest(direction)
    d_x, d_y = *DELTAS[direction]
    raise "tried to go invalid direction (#{direction})" if d_x.nil? or d_y.nil?
    return x + d_x, y + d_y
  end

  def can_move?(direction)
    x, y = *dest(direction)
    !self.map.blocks_movement?(x, y) or self.map.mobs.mob_at?(x, y)
  end

  def move(direction)
    return unless can_move?(direction)
    self.direction = direction
    self.x, self.y = dest(direction)
  end

  def direction_to x, y
    delta_x = delta_y = 0
    delta_x =  1 if x > self.x
    delta_x = -1 if x < self.x
    delta_y =  1 if y > self.y
    delta_y = -1 if y < self.y
    #d "at (#{self.x},#{self.y}) want (#{x},#{y}) delta_x #{delta_x} delta_y #{delta_y}"
    DELTAS.select { |dir, d| d[0] == delta_x and d[1] == delta_y }.keys.first
  end

  def direction_offset(direction, offset)
    (direction + offset + 8) % 8
  end

  def walk_towards x, y
    result = map.pathfinding_cache[ [self.x,self.y,x,y] ]
    result ||= Pathfinder.new(map, { x: self.x, y: self.y }, { x: x, y: y }).search
    # cache the hell out of long routes
    result.each_with_index do |step, i|
      map.pathfinding_cache[ [step.x,step.y,x,y] ] ||= result[i..-1]
    end
    # bug in astar, when pathfinding to one square from current location it
    # will return just [dest] rather than include the origin like it does on
    # every other search
    d "1x pathfinding bug: walk_towards #{self.x},#{self.y} -> #{x},#{y}" if result.empty?
    return if result.empty?
    result.shift if result.first.x == self.x and result.first.y == self.y
    #d "xy #{result.first.x},#{result.first.y} dir #{direction_to(result.first.x, result.first.y)}"
    d "2x pathfinding bug: walk_towards #{self.x},#{self.y} -> #{x},#{y}" if result.empty?
    return if result.empty? # already there
    move(direction_to(result.first.x, result.first.y))
  end
end

end # Ironwood
