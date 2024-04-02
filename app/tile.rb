class Tile
  attr_accessor :edges
  attr_reader :up, :right, :down, :left, :name, :probability

  def initialize(name, edges, probability = 1.0)
    @name = name
    @edges = edges
    @up = []
    @right = []
    @down = []
    @left = []
    @probability = probability
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
