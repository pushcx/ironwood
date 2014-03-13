require 'forwardable'

module Ironwood

class Items
  attr_reader :list

  extend Forwardable
  def_delegators :@list, :<<, :delete, :each, :select

  def initialize list=[]
    @list = list
  end

  def item_at x, y
    each do |item|
      return item if item.x == x and item.y == y
    end
    nil
  end
  alias :item_at? :item_at

  def body_near_player player
    each do |item|
      # not under, just near
      next if item.x == player.x and item.y == player.y
      return item if item.is_a? Body and (item.x - player.x).abs <= 1 and (item.y - player.y).abs <= 1
    end
    nil
  end

end

end # Ironwood
