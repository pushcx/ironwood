#!/usr/bin/env ruby

require 'dispel'

require 'state_machine'

require 'pry'
require 'yaml'

require_relative 'body'
require_relative 'constants'
require_relative 'game'
require_relative 'gen_map'
require_relative 'guard'
require_relative 'item'
require_relative 'items'
require_relative 'map'
require_relative 'map_display'
require_relative 'map_memory'
require_relative 'mobs'
require_relative 'player'
require_relative 'status_bar'
require_relative 'sound'
require_relative 'string_map'
require_relative 'treasure'
require_relative 'game_time'

def d *s
  $DEBUG = File.open('debug.log', 'a')
  $DEBUG.puts *s
  $DEBUG.flush
end

module Ironwood

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

at_exit do
  puts "Score: #{$SCORE}"
end
Dispel::Screen.open(colors: true) do |screen|
  game = Game.new(screen.columns, screen.lines)
  Curses.curs_set(0)

  screen.draw File.read('instructions.txt').split("\n").map { |l| l.center(screen.columns) }.join("\n"), [], [0,0]
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
    when 'g'
      game.map.generate
      game.player.x, game.player.y = $X, $Y
      game.player.on_new_map(game.map, $X, $Y, game.player.direction)
      game.map_display = MapDisplay.new(game.map, screen.columns, screen.lines - 1)
    when ' ','.'
      game.player.act :rest
      game.turn
    when 'd'
      body = game.map.items.body_near_player game.player
      next if not body
      body.x, body.y = game.player.x, game.player.y
      game.player.act :drag
      game.turn
    when *keys_to_directions.keys
      direction = keys_to_directions[key]
      next unless game.player.can_move? direction
      game.player.act :move
      game.player.move direction
      game.turn
    end

    # wipe screen - dispel has a bug where it sometimes leaves the last line
    screen.draw ([' ' * screen.columns] * (screen.lines - 1)).join("\n"), [], [0, 1]
    screen.draw *game.display

    if game.game_over
      screen.draw "Game Over - a guard caught you - score #{game.score}", Dispel::StyleMap.single_line_reversed(screen.columns), [0,0]
      $SCORE = game.score
    end

  end
end

end # Ironwood
