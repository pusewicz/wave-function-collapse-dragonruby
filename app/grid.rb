class Grid
  attr_reader :grid, :width, :height, :options

  def initialize(width, height, options)
    @width = width
    @height = height
    @grid = Array.new(@width) { |x| Array.new(@height) { |y| Cell.new(x, y, options) } }
    @flat = @grid.flatten
    @flat.each { |cell| cell.neighbors(@grid) }
  end

  def lowest_entropy_cells
    cells = @flat.sort_by(&:entropy).filter { |cell| cell.entropy > 1 }

    return if cells.empty?

    initial = cells.first
    cells.select { |cell| cell.entropy == initial.entropy }
  end

  def propagate(cell)
    if (cell_above = cell.neighbors[:up])
      cell.options &= cell_above.options.map(&:down).flatten
      cell_above.options &= cell.options.map(&:up).flatten
    end

    if cell_right = cell.neighbors[:right]
      cell.options &= cell_right.options.map(&:left).flatten
      cell_right.options &= cell.options.map(&:right).flatten
    end

    if (cell_below = cell.neighbors[:down])
      cell.options &= cell_below.options.map(&:up).flatten
      cell_below.options &= cell.options.map(&:down).flatten
    end

    if cell_left = cell.neighbors[:left]
      cell.options &= cell_left.options.map(&:right).flatten
      cell_left.options &= cell.options.map(&:left).flatten
    end
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
