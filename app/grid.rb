class Grid
  attr_reader :grid, :width, :height, :options

  def initialize(width, height, options)
    @width = width
    @height = height
    @options = options.freeze
    @grid = Array.new(@width) { |x| Array.new(@height) { |y| Cell.new(x, y, options) } }
  end

  def heuristic_pick
    cells = @grid.flatten.sort { |a, b| a.entropy <=> b.entropy }.filter { |cell| cell.entropy > 1 }

    return if cells.empty?

    initial = cells.first
    cells.select { |cell| cell.entropy == initial.entropy }.sample
  end

  def collapse
    pick = heuristic_pick 
    return false unless pick
    pick.observe

    @grid.each do |col|
      col.each do |cell|
        next if cell.collapsed

        x = cell.x
        y = cell.y

        x_succ = x.succ
        y_succ = y.succ
        x_pred = (x - 1)
        y_pred = (y - 1)

        next if x_pred.negative? || y_pred.negative? || x_succ >= @width || y_succ >= @height

        cell_above_options = @grid[x][y_succ].options.map(&:down)
        cell_right_options = @grid[x_succ][y].options.map(&:left)
        cell_below_options = @grid[x][y_pred].options.map(&:up)
        cell_left_options = @grid[x_pred][y].options.map(&:right)

        cell.options &= cell_above_options.flatten & cell_right_options.flatten & cell_below_options.flatten & cell_left_options.flatten
      end
    end
  end
end
