#!/usr/bin/ruby

# set up path if run from xinetd
ENV['GEM_PATH'] = '/home/harkins/.gems'
$:.unshift "/home/harkins/code/ironwood"

require 'rubygems'

require 'constants'
require 'rncurses'
require 'map'

class String
  def ord
    self.unpack('c')[0]
  end
end


module Ironwood

demo_dungeon = [
  "##################################################",
  "#..#.........#.#.................................#",
  "#..#..#......###.................................#",
  "#.....#......................#####......#........#",
  "#######......................~~~~#......#........#",
  "#........................~~~~~..~#...............#",
  "#.................~~~~~~~~~......................#",
  "#................~~~~~~..........................#",
  "#........#.......~~~~..................###+###...#",
  "########+#..##....~~~...#..............#.....#...#",
  "#........#.........~~....#.............#.....+...#",
  "#........#........~~......#............#+#####...#",
  "#........#.......~~..............................#",
  "##################################################"
]

movements = {
  'k' => { :direction => DIR_N,  :x =>  0, :y => -1 },
  'u' => { :direction => DIR_NE, :x =>  1, :y => -1 },
  'l' => { :direction => DIR_E,  :x =>  1, :y =>  0 },
  'n' => { :direction => DIR_SE, :x =>  1, :y =>  1 },
  'j' => { :direction => DIR_S,  :x =>  0, :y =>  1 },
  'b' => { :direction => DIR_SW, :x => -1, :y =>  1 },
  'h' => { :direction => DIR_W,  :x => -1, :y =>  0 },
  'y' => { :direction => DIR_NW, :x => -1, :y => -1 },
}

Ncurses.session do |screen|
  x, y = 3, 12
  direction = 0
  map = StringMap.new(demo_dungeon)
  fov = map.fov_for_player(x, y, direction)

  while true # main game loop
    fov.move(x, y, direction)
    map.display(screen, fov)
    key = screen.getch().chr

    break if key == "\033" # escape to quit
    next if not movements.include? key

    change = movements[key]
    next if map.blocks_movement?(x + change[:x], y + change[:y])
    direction = change[:direction]
    x += change[:x]
    y += change[:y]
  end
end

end # Ironwood
