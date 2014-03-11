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
  def color ; '#ff0000' ; end

  def set_state(player)
    if fov.visible? player.x, player.y
      spot_player! if standing_guard?
      @dest_x, @dest_y = player.x, player.y
    else
      if walking? and (x == dest_x and y == dest_y)
        if (x == post_x and y == post_y)
          stand_guard!
        else
          dest_x, dest_y = post_x, post_y
        end
      end
    end
  end

  state_machine :state, initial: :standing_guard do
    event(:lost_player) { transition :walking => :standing_guard }
    event(:stand_guard) { transition :walking => :standing_guard }
    event(:spot_player) { transition :standing_guard => :walking }

    state :standing_guard do
      def turn
      end
    end

    state :walking do
      def turn
        #d "at #{x},#{y}  walking to #{@dest_x},#{dest_y}"
        walk_towards @dest_x, @dest_y
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end
    end
  end
end

end # Ironwood
