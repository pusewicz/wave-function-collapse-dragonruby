class Grid
  attr_reader :grid, :width, :height, :options

  def initialize(width, height, options)
    @width = width
    @height = height
    @grid = Array.new(@width) { |x| Array.new(@height) { |y| Cell.new(x, y, options) } }
    @flat = @grid.flatten
  end

  def lowest_entropy_cells
    cells = @flat.sort_by(&:entropy).filter { |cell| cell.entropy > 1 }

    return if cells.empty?

    initial = cells.first
    cells.select { |cell| cell.entropy == initial.entropy }
  end

  def propagate(cell)
    x = cell.x
    y = cell.y

    y_succ = y + 1
    unless y_succ == @height
      cell_above = @grid[x][y_succ]
      cell.options &= cell_above.options.map(&:down).flatten
      cell_above.options &= cell.options.map(&:up).flatten
    end

    x_succ = x + 1
    unless x_succ == @width
      cell_right = @grid[x_succ][y]
      cell.options &= cell_right.options.map(&:left).flatten
      cell_right.options &= cell.options.map(&:right).flatten
    end

    y_pred = y - 1
    unless y_pred.negative?
      cell_below = @grid[x][y_pred]
      cell.options &= cell_below.options.map(&:up).flatten
      cell_below.options &= cell.options.map(&:down).flatten
    end

    x_pred = x - 1
    return if x_pred.negative?

    cell_left = @grid[x_pred][y]
    cell.options &= cell_left.options.map(&:right).flatten
    cell_left.options &= cell.options.map(&:left).flatten
  end

  def collapse
    cells = lowest_entropy_cells
    return unless cells

    pick = cells.sample
    return unless pick

    pick.observe

    idx = 0
    while idx < cells.size
      propagate(cells[idx])
      idx += 1
    end

    @flat.delete(pick)
  end
end
