
class Cell
  attr_accessor :is_alive, :live_neighbours

  def initialize()
    @live_neighbours = 0
  end

  def to_s
    s = "#{@live_neighbours} live neighbours"
  end
end