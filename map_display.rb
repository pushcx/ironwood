module Ironwood

class MapDisplay
  attr_reader :map, :fov, :width, :height
  def initialize map, fov, width, height
    @map = map
    @fov = fov
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
    lines = map.crop(*crop_dimensions)
    lines[(height / 2)][(width / 2)] = '@'
    lines
  end

  # dear future peter: sorry about this method
  def style_map
    style_map = Dispel::StyleMap.new(height)
    row = col = -1
    ((fov.actor_y - (height / 2))..(fov.actor_y + (height / 2))).each do |y|
      row += 1
      col = -1
      next if y < 0 or y >= map.height
      ((fov.actor_x - (width / 2))..(fov.actor_x + (width / 2))).each do |x|
        col += 1
        d "x,y #{x},#{y} col,row #{col},#{row} vis? #{fov.visible?(x, y)}"
        next if x < 0 or x >= map.width
        if x == fov.actor_x and y == fov.actor_y
          style_map.add(["#dddddd", "#000001"], row, [col])
        else
          if fov.visible?(x, y)
            style_map.add(["#ffffff", "#000000"], row, [col])
          else
            style_map.add(["#000000", "#000000"], row, [col])
          end
        end
      end
    end
    style_map
  end
end

end # Ironwood
