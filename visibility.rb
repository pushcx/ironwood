module Ironwood

module Visibility

  module ShadowCasting
    # Octants are numbered clockwise from NNE
    @@octant_translations = [
      [-1,  0,  0,  1],
      [ 0, -1,  1,  0],
      [ 0, -1, -1,  0],
      [-1,  0,  0, -1],
      [ 1,  0,  0, -1],
      [ 0,  1, -1,  0],
      [ 0,  1,  1,  0],
      [ 1,  0,  0,  1],
    ]

    def calculate(radius)
      8.times do |octant|
        render_octant octant, radius
      end
    end

    private

    def render_octant octant, radius
      cast_visibility(@actor_x, @actor_y, 1, 1.0, 0.0, radius, @@octant_translations[octant][0], @@octant_translations[octant][1], @@octant_translations[octant][2], @@octant_translations[octant][3])
    end

    # based on http://roguebasin.roguelikedevelopment.org/index.php?title=FOV_using_recursive_shadowcasting
    def cast_visibility(start_x, start_y, row, vis_slope_start, vis_slope_end, radius, xx, xy, yx, yy)
      return if vis_slope_start < vis_slope_end

      # 'row' might really be translated to column; names and comments assume octant 0
      (row..radius).each do |i|
        dx, dy = -i - 1, -i
        blocked = false
        # sweep from left to right
        while dx <= 0
          dx += 1

          # Based on the octant, translate the from relative to map coords
          map_x, map_y = start_x + dx * xx + dy * xy, start_y + dx * yx + dy * yy

          # range of the row
          slope_start, slope_end = (dx - 0.5)/(dy + 0.5), (dx + 0.5)/(dy - 0.5)

          # Ignore if not yet at left edge of octant
          next  if slope_end > vis_slope_start
          # Done if past right edge of octant
          break if slope_start < vis_slope_end

          # If it's within range, it's visible
          set_visible(map_x, map_y) if (dx * dx + dy * dy) < (radius * radius)

          if not blocked
            # tile begins a block, do a new cast behind it
            if @map.blocks_visibility?(map_x, map_y) and i < radius
              blocked = true
              cast_visibility(start_x, start_y, i + 1, vis_slope_start, slope_start, radius, xx, xy, yx, yy)
              new_start = slope_end
            end
          else
            # Keep narrowing if scanning across a block
            if @map.blocks_visibility?(map_x, map_y)
              new_start = slope_end
              next
            end

            # block is ended
            blocked = false
            vis_slope_start = new_start
          end
        end
        break if blocked
      end
    end
  end

  module ShadowCasting90d
    include ShadowCasting

    # Directions are numbered clockwise from N
    def calculate(radius)
      [@direction, (@direction - 1 + 8) % 8].each do |oct|
        render_octant oct, radius
      end
    end
  end


  # Tracks what portion of a map is visible to an actor.
  # Currently data is stored as an array (rows) of arrays (cols) of integers (tiles).

  class FieldOfView
    FOV_RADIUS = 12
    #include Visibility::ShadowCasting
    include Visibility::ShadowCasting90d

    attr_reader :actor_x, :actor_y, :direction

    # Pass in a Map of area to do visibility in
    def initialize(map, x, y, direction)
      @map = map
      @data = (0...@map.height).collect { |i| [0] * @map.width }
      @step = 0
      move(x, y, direction)
    end

    # Test if a tile is visible.
    def visible? x, y
      @data[y][x] == @step or (x == actor_x and y == actor_y)
    end

    # For debugging only
    def step x, y
      ('a'.ord + @data[y][x]).chr
    end

    # Mark a tile as visible.
    def set_visible x, y
      @data[y][x] = @step if (0...@map.width).include? x and (0...@map.height).include? y
    end

    # Relocate the center of the FOV
    def move(x, y, direction)
      @actor_x, @actor_y = x, y
      @direction = direction
      @step += 1
      calculate FOV_RADIUS
    end
  end

end

end
