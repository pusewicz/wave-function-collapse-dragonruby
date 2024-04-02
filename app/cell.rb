class Cell
  attr_reader :entropy, :x, :y, :options, :collapsed

  def initialize(x, y, options)
    @x = x
    @y = y
    self.options = options
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
