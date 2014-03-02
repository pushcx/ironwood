require 'rubygems'
require 'ncurses'

module Ncurses
  attr_accessor :start_session_block, :end_session_block

  @start_session ||= lambda do |nc|
    initscr
    noecho
    cbreak
    curs_set 0
    move 0, 0
    clear
    start_color
    refresh
  end

  @end_session ||= lambda do |nc|
    endwin
  end

  def self.session
    begin
      @start_session.call self
      yield self.stdscr
    ensure
      @end_session.call self
    end
  end

  class WINDOW
    @@color_map = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff]

    # rgb values are 0-5 on the 6x6x6 color cube
    def color r, g, b
      color_id = 16 + (r * 36 + g * 6 + b)
      Ncurses.init_color(color_id,
        r / 5.0 * 1000,
        g / 5.0 * 1000,
        b / 5.0 * 1000
      )
      debug "color #{r} #{g} #{b} => #{color_id}"
      color_id
    end

    def color_pair fg, bg
      pair_id = fg * 256 + bg
      Ncurses.init_pair(pair_id, fg, bg)
      Ncurses.COLOR_PAIR(pair_id)
    end

    def puts str, options={}
      #options[:fg] ||= 7
      #options[:bg] ||= 0
      #attrset color_pair(options[:fg], options[:bg])

      options.fetch(:attrs, []).each do |attr|
        attrset attr
      end

      move(options[:y], options[:x]) if options.include? :x and options.include? :y
      addstr str
    end
    
    def debug str
      @debugs ||= 0
      move(20 + @debugs, 0)
      @debugs += 1
      addstr str
    end
  end
end

Ncurses.session do |screen|
  color_count = 0
  256.times do |fg|
    256.times do |bg|
      Ncurses.init_pair(color_count, fg, bg)
      color_count += 1
    end
  end
#  256.times do |fg|
#    #16.times do |bg|
#      i += 1
#      bg = 0
#      #i = fg * 256 + bg
#      #i = bg * 256 + fg
#      #i = fg * bg
#      Ncurses.init_pair(i, fg, bg)
#      #screen.addstr("(#{i} #{fg} #{bg}) ")
#    #end
#  end
  color_count.times do |i|
    screen.attrset(Ncurses.COLOR_PAIR(i))
    screen.addstr("#")
  end
  screen.getch
end
