require './point'
require './cell'
require 'curses'

# Setup magic numbers for console
SCREEN_HEIGHT      = 24
SCREEN_WIDTH       = 80
HEADER_HEIGHT      = 1
HEADER_WIDTH       = SCREEN_WIDTH
MAIN_WINDOW_HEIGHT = SCREEN_HEIGHT - HEADER_HEIGHT
MAIN_WINDOW_WIDTH  = SCREEN_WIDTH

class Game

  attr_accessor :living_cells, :dead_cells_with_neighbours, :living_cells_to_kill, :dead_cells_to_revive

  def initialize(seed_cells)
    @dead_cells_with_neighbours = Hash.new
    @living_cells_to_kill = []
    @dead_cells_to_revive = []

    #initial live cells
    @living_cells = seed_cells

    # update all neighbouring tiles
    @living_cells.each_key do
      |c| neighbours = get_neighbours(c)
      neighbours.each do
        |n| add_neighbour_to_cell(n)
      end
    end
  end

  #increases the number of living neighbours the cell at point has
  def add_neighbour_to_cell(point)
    if @living_cells.has_key?(point)
      @living_cells[point].live_neighbours += 1
    elsif @dead_cells_with_neighbours.has_key?(point)
      @dead_cells_with_neighbours[point].live_neighbours += 1
    else
      @dead_cells_with_neighbours[point] = Cell.new #create new dead cell
      @dead_cells_with_neighbours[point].live_neighbours += 1
    end
  end

  #decreases the number of living neighbours the cell at point has
  def remove_neighbour_from_cell(point)
    if @living_cells.has_key?(point)
      @living_cells[point].live_neighbours -= 1
    elsif @dead_cells_with_neighbours.has_key?(point)
      @dead_cells_with_neighbours[point].live_neighbours -= 1
      if @dead_cells_with_neighbours[point].live_neighbours <= 0 #remove dead cell without neighbours
        @dead_cells_with_neighbours.delete(point)
      end
    end
  end

  def get_neighbours(point) #returns an array of neighbouring points
    x = point.x
    y = point.y
    [
        #top row
        Point.new(x-1, y-1),
        Point.new(x, y-1),
        Point.new(x+1, y-1),

        #left and right
        Point.new(x-1, y),
        Point.new(x+1, y),

        #bottom row
        Point.new(x-1, y+1),
        Point.new(x, y+1),
        Point.new(x+1, y+1)]
  end

  def revive_cell(point)
    cell = @dead_cells_with_neighbours[point]
    if cell.class == NilClass
      cell = Cell.new
    end
    @dead_cells_with_neighbours.delete(point)
    @living_cells[point] = cell
    neighbours = get_neighbours(point)
    neighbours.each do
    |n| add_neighbour_to_cell(n)
    end
  end

  def kill_cell(point)
    if @living_cells.has_key?(point)

      #update living neighbours number
      neighbours = get_neighbours(point)
      neighbours.each do
      |n| remove_neighbour_from_cell(n)
      end

      cell = @living_cells[point]
      @living_cells.delete(point)
      if cell.live_neighbours > 0
        @dead_cells_with_neighbours[point] = cell
      end

    end
  end

  def run
    @dead_cells_to_revive.clear
    @living_cells_to_kill.clear

      @living_cells.each_key do
        |k|
        if @living_cells[k].live_neighbours < 2 || @living_cells[k].live_neighbours > 3
          @living_cells_to_kill << k
        end
      end

      @dead_cells_with_neighbours.each_key do
      |k|
        if @dead_cells_with_neighbours[k].live_neighbours == 3
          @dead_cells_to_revive << k
        end
      end

      @living_cells_to_kill.each do
        |c| kill_cell(c)
      end

      @dead_cells_to_revive.each do
        |c| revive_cell(c)
      end
  end
end

Curses.noecho
Curses.init_screen
window = Curses::Window.new(SCREEN_HEIGHT, SCREEN_WIDTH,0,0)
window.resize(SCREEN_HEIGHT, SCREEN_WIDTH)

=begin /blinker
 game = Game.new(seed = {Point.new(3,5) => Cell.new,
                         Point.new(4,5) => Cell.new,
                         Point.new(5,5) => Cell.new})
=end

# glider
game = Game.new(seed = {Point.new(1,0) => Cell.new,
                        Point.new(2,1) => Cell.new,
                        Point.new(0,2) => Cell.new,
                        Point.new(1,2) => Cell.new,
                        Point.new(2,2) => Cell.new})

while true
  game.run

  window.clear

  game.living_cells.each_key do #draw living cells
    |c| window.setpos(c.y,c.x)
    window << "O"
  end

  window.refresh
  sleep(0.1)
end