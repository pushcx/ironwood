
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
    !self.map.blocks_movement?(*dest(direction))
  end

  def move(direction)
    return unless can_move?(direction)
    self.direction = direction
    self.x, self.y = dest(direction)
  end

  def walk_towards x, y
    delta_x = delta_y = 0
    delta_x += 1 if x > self.x
    delta_x -= 1 if x < self.x
    delta_y += 1 if y > self.y
    delta_y -= 1 if y < self.y
    #d "at (#{self.x},#{self.y}) want (#{x},#{y}) delta_x #{delta_x} delta_y #{delta_y}"
    direction = DELTAS.select { |dir, d| d[0] == delta_x and d[1] == delta_y }.keys.first
    move(direction)
  end
end

end # Ironwood
