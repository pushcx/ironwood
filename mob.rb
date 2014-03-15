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
    @fov = Visibility::FieldOfView.new(map, x, y, direction, Visibility::ShadowCasting90d, GUARD_VIEW_RADIUS)
    @last_actions = []
  end

#  def x=
#    # update fov?
#  end
#  def y=
#  end

  def direction= direction
    raise "attempt to set nil direction" if direction.nil?
    @direction = direction
  end

  def player? ; false ; end
  def tile ; '‽' ; end
  def color ; '#800080' ; end

  def act action
    if action == :rest
      @last_actions = []
    else
      last_actions << action
    end
    last_actions.shift while last_actions.count > 3
    map.make_sound Sound.new(self, :drag) if action == :drag and noise_count >= 3
    map.make_sound Sound.new(self, :run)  if action == :move and noise_count >= 3
  end

  def running?
    last_actions == [:move, :move, :move]
  end

  def noise_count
    last_actions.inject(0) do |acc, action|
      case action
      when :move
        acc + 1
      when :drag
        acc + 2
      else
        acc
      end
    end
  end
end

end # Ironwood
