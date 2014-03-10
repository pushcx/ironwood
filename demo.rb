#!/usr/bin/env ruby

require 'dispel'
require 'pry'
require 'yaml'

require_relative 'constants'
require_relative 'game'
require_relative 'map'
require_relative 'map_display'
require_relative 'map_memory'
require_relative 'player'

def d s
  $DEBUG = File.open('debug.log', 'a')
  $DEBUG.puts s
  $DEBUG.flush
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

map = StringMap.new(demo_dungeon)
Dispel::Screen.open(colors: true) do |screen|
  game = Game.new(map, screen.columns, screen.lines)
  Curses.curs_set(0)

  screen.draw "Ironwood", [], [0,0]
  Dispel::Keyboard.output do |key| # main game loop
    exit if key == :"Ctrl+c" # escape to quit
    exit if key == :escape # escape to quit
    if key == 'P'
      Curses.echo
      Curses.nl
      Curses.close_screen
      binding.pry
      Curses.init_screen
      Curses.noecho
      Curses.nonl
      screen.draw *game.display
    end
    next if not movements.include? key

    change = movements[key]
    next if game.map.blocks_movement?(game.player.x + change[:x], game.player.y + change[:y])
    game.player.direction = change[:direction]
    game.player.x += change[:x]
    game.player.y += change[:y]

    screen.draw *game.display
  end
end

end # Ironwood
