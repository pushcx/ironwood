
module Ironwood

class GameTime
  attr_reader :tick

  def initialize
    @tick = 0
  end
  
  def advance
    @tick += 1
  end

  def previous
    tick - 1
  end
end

end # Ironwood
