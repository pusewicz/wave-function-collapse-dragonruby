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

        cell_above = @grid[x][y.succ.clamp(0, @height - 1)]
        cell.options &= cell_above.options.map(&:down).flatten

        cell_right = @grid[x.succ.clamp(0, @width - 1)][y]
        cell.options &= cell_right.options.map(&:left).flatten

        cell_below = @grid[x][(y - 1).clamp(0, @height - 1)]
        cell.options &= cell_below.options.map(&:up).flatten

        cell_left = @grid[(x - 1).clamp(0, @height - 1)][y]
        cell.options &= cell_left.options.map(&:right).flatten
      end
    end
  end
end
