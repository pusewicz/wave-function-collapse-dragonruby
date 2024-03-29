class Tile
  attr_accessor :edges
  attr_reader :up, :right, :down, :left, :sprite

  def initialize(sprite, edges)
    @sprite = sprite
    @edges = edges
    @up = []
    @right = []
    @down = []
    @left = []
  end

  def rules=(tiles)
    tiles.each do |tile|
      @up << tile if @edges[0] == tile.edges[2]
      @right << tile if @edges[1] == tile.edges[3]
      @down << tile if @edges[2] == tile.edges[0]
      @left << tile if @edges[3] == tile.edges[1]
    end
  end
end

class Cell
  attr_reader :x, :y, :options, :collapsed

  def initialize(x, y, options)
    @x = x
    @y = y
    @options = options
    @collapsed = false
  end

  def sprite
    @options.first.sprite if @collapsed
  end

  def entropy
    @options.size
  end

  def inspect
    to_s
  end

  def to_s
    "Cell #{x}x#{y}, collapsed: #{@collapsed}, entropy: #{entropy}, sprite: #{sprite.inspect}"
  end

  def options=(options)
    raise ArgumentError, "#{x}x#{y} has no options!" if options.empty?
    @collapsed = options.size == 1
    @options = options
  end

  def observe
    self.options = [@options.sample]
  end
end

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

TILE_SIZE = 40

def tick(args)
  if args.state.tick_count == 0
    args.outputs.debug << "Initializing..."
    args.state.options = [
      Tile.new('assets/0.png', [0, 0, 0, 0]),
      Tile.new('assets/1.png', [1, 1, 0, 1]),
      Tile.new('assets/2.png', [1, 1, 1, 0]),
      Tile.new('assets/3.png', [0, 1, 1, 1]),
      Tile.new('assets/4.png', [1, 0, 1, 1]),
      Tile.new('assets/5.png', [1, 0, 1, 0]),
      Tile.new('assets/6.png', [0, 1, 0, 1]),
      Tile.new('assets/c1.png', [1, 1, 0, 0]),
      Tile.new('assets/c2.png', [0, 1, 1, 0]),
      Tile.new('assets/c3.png', [0, 0, 1, 1]),
      Tile.new('assets/c4.png', [1, 0, 0, 1]),
    ]

    args.state.options.each do |tile|
      tile.rules = args.state.options
    end

    args.state.collapsed = false

    args.state.wave = Grid.new(args.grid.w.div(TILE_SIZE), args.grid.h.div(TILE_SIZE), args.state.options)
    args.state.paused = true
  else
    if args.inputs.keyboard.key_down.space
      args.state.paused = !args.state.paused
    end
    args.state.start_time ||= Time.now
    args.state.wave.grid.each do |col|
      col.each do |cell|
        if cell.sprite
          args.outputs.sprites << {
            x: cell.x * TILE_SIZE,
            y: cell.y * TILE_SIZE,
            w: TILE_SIZE,
            h: TILE_SIZE,
            path: cell.sprite
          }.sprite!
        else
          args.outputs.labels << {
            x: cell.x * TILE_SIZE + TILE_SIZE.div(2) ,
            y: cell.y * TILE_SIZE + TILE_SIZE.div(2),
            text: cell.entropy.to_s,
            size_enum: 0,
            alignment_enum: 1,
            vertical_alignment_enum: 1
          }
        end
      end
    end
    # Add debug label on mouse hover of the cell
    x = args.inputs.mouse.x.idiv(TILE_SIZE)
    y = args.inputs.mouse.y.idiv(TILE_SIZE)
    if cell = args.state.wave.grid[x]&.[](y)
      args.outputs.borders << {
        x: x * TILE_SIZE,
        y: y * TILE_SIZE,
        w: TILE_SIZE,
        h: TILE_SIZE,
        r: 255,
        g: 0,
        b: 0
      }
      args.outputs.debug << cell.to_s
    end
    if args.state.collapsed
      args.state.end_time ||= Time.now
      args.outputs.debug << "Collapsed! Took #{args.state.end_time - args.state.start_time} seconds."
    end
    args.outputs.debug << "Paused. Press SPACE to resume." if args.state.paused
    if !args.state.paused && !args.state.collapsed
      time = Time.now
      args.state.collapsed ||= !args.state.wave.collapse
      args.outputs.debug << "Collapsed in #{Time.now - time} seconds."

    end
  end
end
