
module Ironwood

Floor = Struct.new :treasures, :guards, :finished_at

class Score
  attr_reader :floor, :floors, :time

  def initialize time
    @time = time
    @floor = 0
    @floors = [Floor.new(0, 0, 0)]
    new_floor
  end

  def new_floor
    floors[@floor].finished_at = time.tick unless floor == 0
    @floor += 1
    floors[@floor] = Floor.new 0, 0, 0
  end

  def treasure
    floors[@floor].treasures += 1
  end

  def guard
    floors[@floor].guards += 1
  end

  def statusline
    "Floor #{floor} | Time #{time.tick} | Treasures #{total_treasures} | Guards #{total_guards}"
  end

  def total_treasures
    floors.map(&:treasures).inject(0, :+)
  end

  def total_guards
    floors.map(&:guards).inject(0, :+)
  end

  def print_final
    floors.last.finished_at = time.tick
    puts "FINAL SCORE:"
    puts "FLOOR    $    G  Time"
    previous_tick = 0
    floors.each_with_index do |floor, i|
      next if i == 0 # ignore dummy first floor
      print i.to_s.rjust(5)
      print floor.treasures.to_s.rjust(5)
      print floor.guards.to_s.rjust(5)
      print (floor.finished_at - previous_tick).to_s.rjust(6)
      previous_tick = floor.finished_at
    end
    puts
    puts "TOTAL#{total_treasures.to_s.rjust(5)}#{total_guards.to_s.rjust(5)}#{time.tick.to_s.rjust(6)}"
    puts
  end
end

end # Ironwood
