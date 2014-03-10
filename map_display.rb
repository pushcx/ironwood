module Ironwood

class MapDisplay
  attr_reader :map, :fov, :map_memory, :width, :height

  def initialize map, fov, width, height
    @map = map
    @fov = fov
    @map_memory = MapMemory.new(map)
    @width = width
    @height = height
  end

  def crop_dimensions
    [
      fov.actor_x - (width / 2),
      fov.actor_y - (height / 2),
      width,
      height,
    ]
  end

  def view
    map_memory.add fov
    lines = []
    row = -1
    ((fov.actor_y - (height / 2))..(fov.actor_y + (height / 2))).each do |y|
      row += 1
      col = -1
      lines << ' ' * width
      next if y < 0 or y >= map.height
      ((fov.actor_x - (width / 2))..(fov.actor_x + (width / 2))).each do |x|
        col += 1
        next if x < 0 or x >= map.width
        if fov.visible?(x, y)
          lines[row][col] = map.tile(x, y)
        elsif map_memory.remember?(x, y)
          lines[row][col] = map_memory.tile(x, y)
        end
      end
    end
    lines[(height / 2)][(width / 2)] = '@'
    lines
  end

  # dear future peter: sorry about this method
  def style_map
    style_map = Dispel::StyleMap.new(height)
    row = -1
    ((fov.actor_y - (height / 2))..(fov.actor_y + (height / 2))).each do |y|
      row += 1
      col = -1
      next if y < 0 or y >= map.height
      ((fov.actor_x - (width / 2))..(fov.actor_x + (width / 2))).each do |x|
        col += 1
        next if x < 0 or x >= map.width

        if fov.visible?(x, y)
          style_map.add(["#ffffff", "#000000"], row, [col])
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
