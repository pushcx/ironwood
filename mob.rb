require_relative 'movement'

module Ironwood

class Mob
  include Movement

  attr_accessor :map, :x, :y, :direction, :fov, :last_actions

  def initialize map, x, y, direction
    @map = map
    @x = x
    @y = y
    @direction = direction
    @fov = Visibility::FieldOfView.new(map, x, y, direction, Visibility::ShadowCasting90d)
    @last_actions = []
  end

  def player? ; false ; end
  def tile ; '‽' ; end
  def color ; '#800080' ; end

  def act action
    last_actions << action
    last_actions.shift while last_actions.count > 3
  end

  def noise_count
    # [:move, :rest, :move] is 1, not 2, so this is more complicated than select
    last_actions.reverse.inject(0) { |c, a| return c if a != :move; c + 1 }
  end

  def noisy?
    last_actions == [:move, :move, :move]
  end
end

end # Ironwood
