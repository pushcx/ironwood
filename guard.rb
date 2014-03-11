require_relative 'mob'

module Ironwood

class StandingGuard < Mob
  attr_reader :x, :y, :direction
  attr_reader :state
  attr_reader :post_x, :post_y, :post_direction, :dest_x, :dest_y

  def initialize map, x, y, direction
    super
    @post_x, @post_y, @post_direction = x, y, direction
    @dest_x, @dest_y = nil, nil
  end

  def tile ; 'G' ; end
  def color ; hunting? ? '#ff0000' : '#9990ff' ; end

  def set_state(player)
    #d "set_state #{self.tile} #{self.x},#{self.y} - noisy? #{player.noisy?}, hear? #{can_hear_to? player.x, player.y}"
    if fov.visible? player.x, player.y or (player.noisy? and can_hear_to? player.x, player.y)
      spot_player! if standing_guard?
      @dest_x, @dest_y = player.x, player.y
    else
      if (walking? or hunting?) and (x == dest_x and y == dest_y)
        if (x == post_x and y == post_y)
          self.direction = post_direction
          stand_guard!
        else
          lost_player!
          @dest_x, @dest_y = post_x, post_y
        end
      end
    end
  end

  state_machine :state, initial: :standing_guard do
    event(:lost_player) { transition :hunting => :walking }
    event(:stand_guard) { transition [:hunting, :walking] => :standing_guard }
    event(:spot_player) { transition [:walking, :standing_guard] => :hunting }

    state :standing_guard do
      def turn
      end
    end

    state :walking, :hunting do
      def turn
        d "at #{x},#{y} #{state} to #{@dest_x},#{dest_y}"
        walk_towards @dest_x, @dest_y
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end
    end
  end
end

end # Ironwood
