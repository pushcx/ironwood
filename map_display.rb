module Ironwood

class MapDisplay
  attr_reader :map, :fov, :map_memory, :width, :height

  def initialize map, width, height
    @map = map
    @map_memory = MapMemory.new(map)
    @width = width
    @height = height
  end

  def player
    map.mobs.player
  end

  def viewport_tiles
    ((player.fov.actor_y - (height / 2))..(player.fov.actor_y + (height / 2) - 1)).each do |y|
      next if y < 0 or y >= map.height
      ((player.fov.actor_x - (width / 2))..(player.fov.actor_x + (width / 2))).each do |x|
        next if x < 0 or x >= map.width

        col, row = xy_to_colrow x, y
        yield x, y, col, row
      end
    end

  end

  def xy_to_colrow x, y
    return (x - player.fov.actor_x) + (width / 2), (y - player.fov.actor_y) + (height / 2)
  end

  def view
    map_memory.add player.fov
    lines = []
    # first pass, lay down the terrain
    viewport_tiles do |x, y, col, row|
      #d "#{x},#{y} -> #{col},#{row}"
      lines[row] ||= ' ' * width
      if player.fov.visible?(x, y)
        lines[row][col] = map.tile(x, y)
      elsif map_memory.remember?(x, y)
        lines[row][col] = map_memory.tile(x, y)
      end
    end

    # second pass, add sounds (bad big o here, sounds * tiles)
    map.sounds_heard_by(player).each do |sound|
      col, row = xy_to_colrow sound.x, sound.y
      lines[row][col] = '!'
    end

    # third pass, add mobs
    map.mobs.each do |mob|
      if player.fov.visible? mob.x, mob.y
        col, row = xy_to_colrow mob.x, mob.y
        next if col < 0 or col >= width or row < 0 or row >= height
        lines[row][col] = mob.tile
      end
    end
    lines
  end

  # dear future peter: sorry about this method
  def style_map
    style_map = Dispel::StyleMap.new(height)
    # first pass, highlight the terrain
    viewport_tiles do |x, y, col, row|
      if player.fov.visible?(x, y)
        if map.mobs.mob_at? x, y
          mob = map.mobs.mob_at x, y
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

    # second pass, highlight mobvision
    map.mobs.each do |mob|
      next if mob.player?
      next unless player.fov.visible? mob.x, mob.y
      viewport_tiles do |x, y, col, row|
        if mob.fov.visible?(x, y) and map_memory.remember?(x, y)
          style_map.add([mob.color, '#000000'], row, [col])
        end
      end
    end

    # third pass (yes, not same order as view), show sounds
    map.sounds_heard_by(player).each do |sound|
      col, row = xy_to_colrow sound.x, sound.y
      style_map.add([SOUND_COLOR, '#000000'], row, [col])
    end

    style_map
  end
end

end # Ironwood
