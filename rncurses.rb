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
    def puts str, options={}
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
