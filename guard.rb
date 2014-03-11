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

  def order_walk_to x, y
    order_walk!
    @dest_x, @dest_y = x, y
  end

  def spot? player
    return false unless fov.visible? player.x, player.y
    @dest_x, @dest_y = player.x, player.y
    hunt! unless hunting?
    true
  end

  def hear? player
    return true if hunting?
    return false unless player.noisy? and can_hear_to? player.x, player.y
    hunt!
    @dest_x, @dest_y = player.x, player.y
  end

  def decide_state(player)
    #d "decide_state #{self.tile} (#{state}) at (#{self.x},#{self.y}) dest (#{@dest_x},#{dest_y}) - noisy? #{player.noisy?}, hear? #{can_hear_to? player.x, player.y}"
    return if spot? player
    return if hear? player
    return if standing_guard?

    decide_arrived?
  end

  state_machine :state, initial: :standing_guard do
    event(:lost_player) { transition :hunting => :walking }
    event(:order_walk)  { transition all => :walking }
    event(:stand_guard) { transition [:hunting, :walking] => :standing_guard }
    event(:hunt) { transition [:walking, :standing_guard] => :hunting }

    state :standing_guard do
      def turn
        walk_cyle_state = :move
        peek_cyle_state = :forward1
      end
    end

    state :hunting do
      def turn
        #d "at #{x},#{y} #{state} to #{@dest_x},#{dest_y}"
        walk_towards @dest_x, @dest_y
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end

      def decide_arrived?
        if x == post_x and y == post_y
          stand_guard!
          self.direction = post_direction
        end
        if x == dest_x and y == dest_x
          order_walk!
          @dest_x, @dest_y = post_x, post_y
        end
      end
    end

    state :walking do
      def turn
        #d "at #{x},#{y} #{state} (#{walk_cycle_state}, #{peek_cycle_state}) to #{@dest_x},#{dest_y}"
        walk_cycle_turn
        walk_cycle_step!
      end

      def decide_arrived?
        if x == dest_x and y == dest_x
          lost_player!
          @dest_x, @dest_y = post_x, post_y
        end
      end
    end
  end

  state_machine :walk_cycle_state, initial: :move do
    event(:walk_cycle_step) {
      transition :rest => :move
      transition :move => :rest
    }

    state :rest do
      def walk_cycle_turn
        peek_cycle_turn
        peek_cycle_step!
      end
    end

    state :move do
      def walk_cycle_turn
        walk_towards @dest_x, @dest_y
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end
    end
  end

  state_machine :peek_cycle_state, initial: :right do
    event(:peek_cycle_step) {
      transition :right => :left
      transition :left => :right
    }

    state :right do
      def peek_cycle_turn
        self.direction = direction_offset(direction_to(@dest_x, @dest_y),  1)
      end
    end

    state :left do
      def peek_cycle_turn
        self.direction = direction_offset(direction_to(@dest_x, @dest_y), -1)
      end
    end
  end
end

end # Ironwood
