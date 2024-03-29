class Cell
  attr_reader :x, :y, :options, :collapsed

  def initialize(x, y, options)
    @x = x
    @y = y
    @options = options
    @collapsed = false
  end

  def name
    @options.first.name if @collapsed
  end

  def entropy
    @options.size
  end

  def inspect
    to_s
  end

  def to_s
    "Cell #{x}x#{y}, collapsed: #{@collapsed}, entropy: #{entropy}, name: #{name.inspect}"
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

