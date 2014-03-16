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
require_relative 'score'
require_relative 'status_bar'
require_relative 'staircase'
require_relative 'sound'
require_relative 'string_map'
require_relative 'trapdoor'
require_relative 'treasure'
require_relative 'game_time'

$DEBUG_FLAG = ARGV.first == '-d'

def d *s
  return unless $DEBUG_FLAG
  $DEBUG ||= File.open('debug.log', 'a')
  $DEBUG.puts *s
  $DEBUG.flush
end
d '-' * 40

module Ironwood

keys_to_directions = {
  'k' => DIR_N,
  'u' => DIR_NE,
  'l' => DIR_E,
  'n' => DIR_SE,
  'j' => DIR_S,
  'b' => DIR_SW,
  'h' => DIR_W,
  'y' => DIR_NW,

  :up        => DIR_N,
  :page_up   => DIR_NE,
  :right     => DIR_E,
  :page_down => DIR_SE,
  :down      => DIR_S,
  :end       => DIR_SW,
  :left      => DIR_W,
  :home      => DIR_NW,

  "^Ox" => DIR_N,
  349   => DIR_NE,
  "^Ov" => DIR_E,
  352   => DIR_SE,
  "^Or" => DIR_S,
  351   => DIR_SW,
  "^Ot" => DIR_W,
  348   => DIR_NW,
}

at_exit do
  $SCORE.print_final if $SCORE
end
Dispel::Screen.open(colors: true) do |screen|
  game = Game.new(screen.columns, screen.lines)
  Curses.curs_set(0)

  screen.draw File.read('instructions.txt').split("\n").map { |l| l.center(screen.columns) }.join("\n"), [], [0,0]
  Dispel::Keyboard.output do |key| # main game loop
    #d "#{key} #{key.class} #{key.length if key.respond_to? :length}"
    exit if game.game_over
    case key
    when :"Ctrl+c"
      exit
    when 'P'
      next unless $DEBUG_FLAG
      Curses.echo
      Curses.nl
      Curses.close_screen
      binding.pry
      Curses.init_screen
      Curses.noecho
      Curses.nonl
    when 'g'
      next unless $DEBUG_FLAG
      game.score.new_floor
      game.map = GenMap.new(game.time)
      game.player.on_new_map(game.map, $X, $Y, game.player.direction)
      game.map_display = MapDisplay.new(game.map, screen.columns, screen.lines - 1)
    when '>'
      item = game.map.items.item_at? game.player.x, game.player.y
      next unless item and item.is_a? Staircase
      game.new_floor
    when ' ','.',350,'5'
      game.player.act :rest
      game.turn
    when 's'
      next unless game.player.smokebombs > 0
      game.player.smokebombs -= 1
      game.map.mobs_seen_by(game.player).each do |mob|
        mob.smokebomb!
      end
      game.player.act :stun
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
      screen.draw "Game Over - a guard caught you", Dispel::StyleMap.single_line_reversed(screen.columns), [0,0]
      $SCORE = game.score
    end

  end
end

end # Ironwood
