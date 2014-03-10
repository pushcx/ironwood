module Ironwood

class MapDisplay
  attr_reader :map, :fov, :map_memory, :width, :height
  attr_accessor :mobs

  def initialize map, mobs, width, height
    @map = map
    @map_memory = MapMemory.new(map)
    @width = width
    @height = height
    @mobs = mobs
  end

  def player
    mobs.player
  end

  def view
    map_memory.add player.fov
    lines = []
    row = -1
    ((player.fov.actor_y - (height / 2))..(player.fov.actor_y + (height / 2))).each do |y|
      row += 1
      col = -1
      lines << ' ' * width
      next if y < 0 or y >= map.height
      ((player.fov.actor_x - (width / 2))..(player.fov.actor_x + (width / 2))).each do |x|
        col += 1
        next if x < 0 or x >= map.width
        if player.fov.visible?(x, y)
          if mobs.mob_at? x, y
            lines[row][col] = mobs.mob_at(x, y).tile
          else
            lines[row][col] = map.tile(x, y)
          end
        elsif map_memory.remember?(x, y)
          lines[row][col] = map_memory.tile(x, y)
        end
      end
    end
    lines
  end

  # dear future peter: sorry about this method
  def style_map
    style_map = Dispel::StyleMap.new(height)
    row = -1
    ((player.fov.actor_y - (height / 2))..(player.fov.actor_y + (height / 2))).each do |y|
      row += 1
      col = -1
      next if y < 0 or y >= map.height
      ((player.fov.actor_x - (width / 2))..(player.fov.actor_x + (width / 2))).each do |x|
        col += 1
        next if x < 0 or x >= map.width

        if player.fov.visible?(x, y)
          if mobs.mob_at? x, y
            mob = mobs.mob_at x, y
            style_map.add([mob.color, "#000000"], row, [col])
          else
            style_map.add(["#ffffff", "#000000"], row, [col])
          end
        elsif map_memory.remember?(x, y)
          style_map.add(["#666666", "#000000"], row, [col])
        else
          style_map.add(["#000000", "#000000"], row, [col])
        end
      end
    end
    style_map
  end
end

end # Ironwood
