require 'dispel'

# Dispel assumes a 256-color terminal. Most people don't have this. And oddly,
# even in a 256-color term, it never switches into that mode properly so I
# still only get the default 16 ANSI colors.
#
# But basically nobody has a 256 color terminal and the games assumes the ANSI
# 16, so this hack takes the colors I used in Ironwood and maps them to the
# corresponding 16 ANSI values.
#
# Well, after tinkering, it's worse than that. Dispel can't properly use
# 16 colors, so I've hacked it down to 8, because I have no more patience
# for 35-year-old broken standards.

module Dispel
  class Screen
    def self.html_to_terminal_color hex
      IRONWOOD_COLORS[hex]
    end
  end
end

IRONWOOD_COLORS = {
  '#000000' => 0,
  '#0000ff' => 5,#13,
  '#00ff00' => 2,#10,
  '#222334' => 4,
  '#666666' => 6, # 8
  '#800080' => 5,#13,
  '#9990ff' => 5,#13,
  '#9999ff' => 5,#13,
  '#aa5500' => 4,
  '#dddddd' => 6,#14,
  '#ff0000' => 1,
  '#ff00ff' => 5,#13,
  '#ffff00' => 3,#11,
  '#ffffff' => 7,#15,
}


