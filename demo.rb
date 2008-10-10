#!/usr/bin/ruby

# set up path if run from xinetd
ENV['GEM_PATH'] = '/home/harkins/.gems'
$:.unshift "/home/harkins/code/ironwood"

require 'rubygems'

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
  'k' => { :direction => 0, :x =>  0, :y => -1 },
  'u' => { :direction => 1, :x =>  1, :y => -1 },
  'l' => { :direction => 2, :x =>  1, :y =>  0 },
  'n' => { :direction => 3, :x =>  1, :y =>  1 },
  'j' => { :direction => 4, :x =>  0, :y =>  1 },
  'b' => { :direction => 5, :x => -1, :y =>  1 },
  'h' => { :direction => 6, :x => -1, :y =>  0 },
  'y' => { :direction => 7, :x => -1, :y => -1 },
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
