#!/usr/bin/env ruby

require 'dispel'
require 'state_machine'
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

keys_to_directions = {
  'k' =>  DIR_N,
  'u' =>  DIR_NE,
  'l' =>  DIR_E,
  'n' =>  DIR_SE,
  'j' =>  DIR_S,
  'b' =>  DIR_SW,
  'h' =>  DIR_W,
  'y' =>  DIR_NW,
}

map = StringMap.new(demo_dungeon)
Dispel::Screen.open(colors: true) do |screen|
  game = Game.new(map, screen.columns, screen.lines)
  #game = Game.new(map, 5,5)
  Curses.curs_set(0)

  screen.draw "Ironwood", [], [0,0]
  Dispel::Keyboard.output do |key| # main game loop
    exit if game.game_over
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
      game.turn
    when *keys_to_directions.keys
      direction = keys_to_directions[key]
      next unless game.player.can_move? direction
      game.player.move direction
      game.turn
    end

    # wipe screen - dispel has a bug where it sometimes leaves the last line
    screen.draw ([' ' * screen.columns] * (screen.lines - 1)).join("\n"), [], [0, 1]
    screen.draw *game.display

    if game.game_over
      screen.draw "Game Over - a guard caught you", Dispel::StyleMap.single_line_reversed(screen.columns), [0,0]
    end

  end
end

end # Ironwood
