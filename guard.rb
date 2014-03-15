require_relative 'mob'

module Ironwood

class Guard < Mob
  attr_reader :x, :y, :direction
  attr_reader :state
  attr_reader :post_x, :post_y, :post_direction, :dest_x, :dest_y
  attr_accessor :stun

  def initialize map, x, y, direction
    super
    @post_x, @post_y, @post_direction = x, y, direction
    @dest_x, @dest_y = nil, nil
    @patrol_x, @patrol_y = nil, nil
    @stun = 0
  end

  def tile ; 'G' ; end
  def color
    if raging? or hunting?
      '#ff0000'
    elsif stunned?
      '#ffff00'
    else
      '#9990ff'
    end
  end

  def order_walk_to x, y
    # can't get there, skip
    return if direction_to(x, y).nil?
    order_walk!
    @dest_x, @dest_y = x, y
  end

  def order_patrol_to x, y
    @patrol_x, @patrol_y = x, y
    order_walk_to x, y
  end

  def spot? player
    return false unless fov.visible? player.x, player.y
    #d " - spot at #{player.x},#{player.y}"
    @dest_x, @dest_y = player.x, player.y
    yell! unless yelling? or hunting?
    true
  end

  def see_body?
    map.items_seen_by(self).each do |item|
      next unless item.is_a? Body
      @dest_x, @dest_y = item.x, item.y
      rage!
    end
    false
  end

  def hear? player
    return false if hunting? # can't hear when running
    sound = map.sound_heard_by(self)
    return false unless sound
    #d " - hear at #{sound.x},#{sound.y}"
    @dest_x, @dest_y = sound.x, sound.y
    hunt! unless hunting?
    true
  end

  def stun_remaining?
    @stun -= 1 if @stun > 0
    @stun > 0
  end

  def decide_state(player)
    d "decide_state #{self.tile} (#{state} #{stun}) at (#{self.x},#{self.y}) dest (#{@dest_x},#{dest_y})"
    return if stun_remaining?
    return if spot? player
    return if see_body?
    return if hear? player
    return if standing_guard?

    decide_arrived?
  end

  state_machine :state, initial: :standing_guard do
    event(:lost_player) { transition :hunting => :walking }
    event(:order_walk)  { transition all => :walking }
    event(:stand_guard) { transition [:stunned, :hunting, :walking] => :standing_guard }
    event(:yell) { transition [:walking, :standing_guard] => :yelling }
    event(:hunt) { transition [:walking, :standing_guard, :raging, :yelling] => :hunting }
    event(:rage) { transition all => :raging }
    event(:smokebomb) { transition all => :stunned }

    after_transition any => :stunned do |mob, transition|
      mob.stun += 9
    end

    state :stunned do
      def turn
        #d "stunned mob #{x},#{y} ignores turn #{stun}"
      end
      def decide_arrived?
        return if stun > 0
        if have_destination?
          order_walk_to(@dest_x, @dest_y)
        elsif !at_post?
          order_walk_to(@post_x, @post_y)
        else
          stand_guard!
        end
      end
    end

    state :standing_guard do
      def turn
        walk_cyle_state = :move
        peek_cyle_state = :forward1
      end
    end

    state :yelling do
      def turn
        map.make_sound Sound.new(self, :yell)
        hunt!
      end
    end

    state :hunting do
      def turn
        #d "#{self.object_id}  at #{x},#{y} #{state} to #{@dest_x},#{@dest_y}" if patrolling?
        walk_towards @dest_x, @dest_y
        act :move
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end


      def decide_arrived?
        return unless at_destination?

        lost_player!
        @dest_x, @dest_y = post_x, post_y
        ##d  "  - yep, arrived, new dest is #{@dest_x},#{@dest_y} #{state}"
      end
    end

    state :raging do
      def turn
        #d "#{self.object_id}  at #{x},#{y} #{state} to #{@dest_x},#{@dest_y}"
        map.make_sound Sound.new(self, :yell) if rand(5) == 0
        walk_towards @dest_x, @dest_y
        act :move
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y if fov.visible? player.x, player.y
      end

      def decide_arrived?
        return false unless at_destination?
        player = map.mobs.player
        @dest_x, @dest_y = player.x, player.y
        hunt!
      end
    end

    state :walking do
      def turn
        #d "#{self.object_id}  at #{x},#{y} #{state} (#{walk_cycle_state}, #{peek_cycle_state}) to #{@dest_x},#{@dest_y}" if patrolling?
        #d "at #{x},#{y} #{state} (#{walk_cycle_state}, #{peek_cycle_state}) to #{@dest_x},#{dest_y}"
        walk_cycle_turn
        walk_cycle_step!
      end

      def decide_arrived?
        return unless at_destination?
        #d "#{self.object_id} reached destination #{@dest_x},#{@dest_y}"

        if at_post?
          #d "#{self.object_id} is at post #{@post_x},#{@post_y}"
          if patrolling?
            #d "#{self.object_id} ordering to patrol #{@patrol_x},#{@patrol_y}"
            order_walk_to @patrol_x, @patrol_y
          else
            stand_guard!
            self.direction = post_direction
          end
        else
          #d "#{self.object_id} is NOT at post; ordering to post #{@post_x},#{@post_y}"
          order_walk_to @post_x, @post_y
        end
      end
    end
  end

  def at_destination?
    x == @dest_x and y == @dest_y
  end

  def have_destination?
    @dest_x and @dest_y
  end

  def at_post?
    x == @post_x and y == @post_y
  end

  def at_patrol?
    x == @patrol_x and y == @patrol_y
  end

  def patrolling?
    @patrol_x and @patrol_y
  end

  state_machine :walk_cycle_state, initial: :move do
    event(:walk_cycle_step) {
      transition :rest => :move
      transition :move => :rest
    }

    state :rest do
      def walk_cycle_turn
        act :rest
        peek_cycle_turn
        peek_cycle_step!
      end
    end

    state :move do
      def walk_cycle_turn
        act :move
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
        # papering over a bug here, sometimes direction_to is returning nil
        dir = direction_to(@dest_x, @dest_y)
        return if dir.nil?
        self.direction = direction_offset(dir,  1)
      end
    end

    state :left do
      def peek_cycle_turn
        dir = direction_to(@dest_x, @dest_y)
        return if dir.nil?
        self.direction = direction_offset(dir, -1)
      end
    end
  end
end

end # Ironwood
