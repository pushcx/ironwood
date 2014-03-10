require_relative 'mob'

module Ironwood

class StandingGuard < Mob
  attr_reader :x, :y, :direction
  attr_reader :state

  def initialize map, x, y, direction
    super
    @post_x, @post_y, @post_direction = x, y, direction
  end

  def tile ; 'G' ; end
  def color ; '#ff0000' ; end

  def set_state(player)
    if standing_guard? and fov.visible? player.x, player.y
      spot_player!
    end
    if chasing? and !(fov.visible? player.x, player.y)
      lost_player!
    end
  end


  state_machine :state, initial: :standing_guard do
    event :lost_player do
      transition :chasing => :standing_guard
    end

    event :spot_player do
      transition :standing_guard => :chasing
    end

    state :standing_guard do
      def turn(player)
      end
    end

    state :chasing do
      def turn(player)
        chase(player)
      end
    end
  end
end

end # Ironwood
