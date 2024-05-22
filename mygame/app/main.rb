require_relative "tile"
require_relative "cell"
require_relative "model"

RED = { r: 255, g: 0, b: 0 }
GREEN = { r: 0, g: 255, b: 0 }
WHITE = { r: 255, g: 255, b: 255 }
BLACK = { r: 0, g: 0, b: 0 }
GRAY = { r: 190, g: 190, b: 190 }
WIDTH = 1280
HEIGHT = 720

def boot(args)
  defaults
end

def defaults
  @map_json = GTK.parse_json_file("assets/map.tsj")
  @tile_width = @map_json["tilewidth"]
  @tile_height = @map_json["tileheight"]
  @tile_columns = @map_json["columns"]
  @tile_rows = @map_json["tilecount"] / @tile_columns
  @tiles = { path: "assets/#{@map_json["image"]}", w: @tile_width, h: @tile_height, tile_w: @tile_width, tile_h: @tile_height }.freeze
  @times = []
  @paused = false
  @labels = []
  @model = Model.new(build_tiles, WIDTH.div(@tile_width), HEIGHT.div(@tile_height))
  @map = nil
  @started_at = Time.now.to_f
  @finished_at = nil
end

def reset
  defaults
end

def tick(args)
  update(args)
  draw(args)
end

def update(args)
  @labels = []
  @map = @model.solve if @map.nil?

  return if @paused

  unless @model.complete?
    time_start = Time.now.to_f
    @map = @model.iterate
    @times << Time.now.to_f - time_start
  end

end

def draw(args)
  args.outputs.background_color = BLACK
  if @model.complete?
    @finished_at ||= Time.now.to_f
    time = @finished_at - @started_at
    add_label("Map generated in #{"%02.2f" % time}s")
    add_label("Press A to add row.")
  else
    time = Time.now.to_f - @started_at
    add_label("Generating #{@model.width}x#{@model.height}. Elapsed #{"%02.2f" % time}s. #{"%02.2f" % @model.percent}% complete.")
    add_label("Press P to pause/unpause, R to restart.")
  end
  if (last_time = @times.last)
    mss = last_time * 1000
    color = (mss > 16) ? RED : GREEN
    add_label("Last iteration: #{"%03.2f" % mss}ms", color)
  end
  draw_map(args)

  average_time_mss = (@times.sum / @times.size.to_f) * 1000
  add_label("AVG(mss)=#{"%03.2f" % average_time_mss}ms", (average_time_mss > 16) ? RED : GREEN)

  p90_time = @times.sort[(@times.size * 0.9).to_i] * 1000
  add_label("P90(mss)=#{"%03.2f" % p90_time}ms", (p90_time > 16) ? RED : GREEN)

  p99_time = @times.sort[(@times.size * 0.99).to_i] * 1000
  add_label("P99(mss)=#{"%03.2f" % p99_time}ms", (p99_time > 16) ? RED : GREEN)

  if @paused
    args.outputs.labels << {
      x: WIDTH / 2,
      y: HEIGHT / 2,
      text: "Paused",
    }
  end

  draw_labels(args)
end

def version_label
  @label ||= [[RUBY_ENGINE, RUBY_VERSION].join("/"), ["dragonruby", GTK.version].join("/"), GTK.platform].join(" ")
end

def add_label(text, color = WHITE)
  @labels << [text, color]
end

def draw_labels(args)
  labels = []
  @labels.each_with_index do |(text, color), offset|
    labels << {
      x: 5,
      y: 5.from_top - (offset * 16 * 1.2),
      text: text,
      size_enum: -4,
    }.merge(BLACK)
    labels << {
      x: 4,
      y: 4.from_top - (offset * 16 * 1.2),
      text: text,
      size_enum: -4,
    }.merge(color)
  end

  labels << {
    x: WIDTH - 3,
    y: 14,
    text: version_label,
    alignment_enum: 2,
    size_enum: -4,
  }.merge(BLACK)
  labels << {
    x: WIDTH - 4,
    y: 15,
    text: version_label,
    alignment_enum: 2,
    size_enum: -4,
  }.merge(GRAY)
  args.outputs.labels.concat labels
end

def draw_map(args)
  tiles = []
  labels = []
  @map.each_with_index do |column, x|
    column.each_with_index do |tile, y|
      entropy = @model.cell_at(x, y).entropy

      if entropy > 1
        percent_entropy = (entropy.to_f / @model.max_entropy * 255).round
        color = { a: 160, r: percent_entropy, g: 255 - percent_entropy, b: 0 }
        labels << {
          x: x * @tile_width + (@tile_width / 2),
          y: y * @tile_height + (@tile_height / 2) + 6,
          text: entropy,
          size_enum: -4,
          alignment_enum: 1
        }.merge(color)
      end

      next unless tile

      tile_y, tile_x = tile.tileid.divmod(@tile_columns)
      tiles << @tiles.merge(
        x: x * @tile_width,
        y: y * @tile_height,
        tile_x: tile_x * @tile_width,
        tile_y: tile_y * @tile_height,
      )
    end
  end
  args.outputs.sprites.concat tiles
  args.outputs.labels.concat labels
end

def build_tiles
  @map_json["wangsets"].last["wangtiles"].map do |tile|
    # TODO: Probability can also be defined in the wangset
    prob = @map_json["tiles"]&.find { |t| t["id"] == tile["tileid"] }&.fetch("probability")
    Tile.new(
      tileid: tile["tileid"],
      wangid: tile["wangid"],
      probability: prob
    )
  end
end
