class Cell
  attr_reader :entropy, :x, :y, :options, :collapsed

  def initialize(x, y, options)
    @x = x
    @y = y
    @neighbors = nil
    self.options = options
  end

  def neighbors(grid = nil)
    return @neighbors if grid.nil?

    @neighbors ||= begin
      up = grid[@x][@y + 1] if grid[@x] && @y < grid[0].length - 1
      down = grid[@x][@y - 1] if grid[@x] && @y.positive?
      right = grid[@x + 1][@y] if @x < grid.length - 1
      left = grid[@x - 1][@y] if @x.positive?
      { up: up, down: down, right: right, left: left }
    end
  end

  def name
    @options.first.name if @collapsed
  end

  def inspect
    to_s
  end

  def to_s
    "Cell #{@x}x#{@y} collapsed: #{@collapsed}, entropy: #{@entropy}, name: #{@name}"
  end

  def options=(options)
    raise ArgumentError, "#{@x}x#{@y} has no options!" if options.empty?

    @entropy = options.size
    @collapsed = @entropy == 1
    @options = options
  end

  def observe
    self.options = [@options.sample]
  end
end
