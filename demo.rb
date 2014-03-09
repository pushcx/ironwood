#!/usr/bin/env ruby

require 'dispel'
require 'yaml'

require_relative 'constants'
require_relative 'map'
require_relative 'game'

#class String
#  def ord
#    self.unpack('c')[0]
#  end
#end
#

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

def self.d s
  puts s
end

map = StringMap.new(demo_dungeon)
game = Game.new(map)
Dispel::Screen.open(colors: true) do |screen|
  Curses.curs_set(0)

  screen.draw "Ironwood", [], [0,0]
  Dispel::Keyboard.output do |key| # main game loop
    screen.draw *game.display

    exit if key == :"Ctrl+c" # escape to quit
    exit if key == :escape # escape to quit
    next if not movements.include? key

    change = movements[key]
    d change.to_yaml
    next if game.map.blocks_movement?(game.x + change[:x], game.y + change[:y])
    game.direction = change[:direction]
    game.x += change[:x]
    game.y += change[:y]
  end
end

end # Ironwood
