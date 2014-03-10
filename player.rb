require_relative 'mob'

module Ironwood

class Player < Mob
  def player? ; true ; end
  def tile ; '@' ; end
  def color ; '#9999ff' ; end
end

end # Ironwood
