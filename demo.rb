#!/usr/bin/env ruby

require 'dispel'
require 'pry'
require 'yaml'

require_relative 'constants'
require_relative 'game'
require_relative 'guard'
require_relative 'map'
require_relative 'map_display'
require_relative 'map_memory'
require_relative 'mobs'
require_relative 'player'
require_relative 'status_bar'
require_relative 'game_time'

def d *s
  $DEBUG = File.open('debug.log', 'a')
  $DEBUG.puts *s
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
  #game = Game.new(map, 5,5)
  Curses.curs_set(0)

  screen.draw "Ironwood", [], [0,0]
  Dispel::Keyboard.output do |key| # main game loop
    case key
    when :"Ctrl+c"
      exit
    when 'P'
      Curses.echo
      Curses.nl
      Curses.close_screen
      binding.pry
      Curses.init_screen
      Curses.noecho
      Curses.nonl
    when ' '
      game.time.advance
    when *movements.keys
      game.time.advance
      change = movements[key]
      next if game.map.blocks_movement?(game.player.x + change[:x], game.player.y + change[:y])
      game.player.direction = change[:direction]
      game.player.x += change[:x]
      game.player.y += change[:y]
    end

    # wipe screen - dispel has a bug where it sometimes leaves the last line
    screen.draw ([' ' * screen.columns] * (screen.lines - 1)).join("\n"), [], [0, 1]
    screen.draw *game.display
  end
end

end # Ironwood
