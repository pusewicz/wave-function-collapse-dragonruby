require_relative "config"
require_relative "tile"
require_relative "cell"
require_relative "grid"

def tick(args)
  if args.state.tick_count.zero?
    args.outputs.debug << "Initializing..."
    args.state.options = Config::RULES.map do |name, opts|
      Tile.new(name, opts[:edges], opts[:probability])
    end

    args.state.options.each do |tile|
      tile.rules = args.state.options
    end

    args.state.collapsed = false
    args.state.iterations = 1

    args.state.wave = Grid.new(args.grid.w.div(Config::TILE_SIZE), args.grid.h.div(Config::TILE_SIZE),
                               args.state.options)
    args.state.paused = true
    args.outputs.debug << "Initialized!"
  else
    args.outputs.debug << "FPS: #{args.gtk.current_framerate.to_sf}"
    args.state.paused = !args.state.paused if args.inputs.keyboard.key_down.space
    args.state.start_time ||= Time.now

    tiles = []
    borders = []
    labels = []
    x = 0
    while x < args.state.wave.width
      y = 0
      while y < args.state.wave.height
        cell = args.state.wave.grid[x][y]
        if cell.name
          tiles << {
            x: x * Config::TILE_SIZE,
            y: y * Config::TILE_SIZE,
            w: Config::TILE_SIZE,
            h: Config::TILE_SIZE,
            path: Config::SPRITES[cell.name]
          }.sprite!
        else
          borders << {
            x: x * Config::TILE_SIZE,
            y: y * Config::TILE_SIZE,
            w: Config::TILE_SIZE,
            h: Config::TILE_SIZE,
            r: 0,
            g: 128,
            b: 0,
            a: 128
          }
          labels << {
            x: (x * Config::TILE_SIZE) + Config::TILE_SIZE.div(2),
            y: (y * Config::TILE_SIZE) + Config::TILE_SIZE.div(2) - 1,
            text: cell.entropy.to_s,
            size_enum: -4,
            alignment_enum: 1,
            vertical_alignment_enum: 1
          }.merge(cell.entropy < args.state.options.size ? { r: 0, g: 0, b: 255 } : {}).label!
        end
        y += 1
      end
      x += 1
    end

    args.outputs.sprites << tiles
    args.outputs.borders << borders
    args.outputs.labels << labels

    # Add debug label on mouse hover of the cell
    x = args.inputs.mouse.x.idiv(Config::TILE_SIZE)
    y = args.inputs.mouse.y.idiv(Config::TILE_SIZE)
    if (cell = args.state.wave.grid[x]&.[](y))
      args.outputs.borders << {
        x: x * Config::TILE_SIZE,
        y: y * Config::TILE_SIZE,
        w: Config::TILE_SIZE,
        h: Config::TILE_SIZE,
        r: 255,
        g: 0,
        b: 0
      }
      args.outputs.debug << cell.to_s
    end
    if args.state.collapsed
      args.state.end_time ||= Time.now
      args.outputs.debug << "Collapsed! Took #{(args.state.end_time - args.state.start_time).to_sf} seconds."
    end
    args.outputs.debug << "Paused. Press SPACE to resume." if args.state.paused
    if !args.state.paused && !args.state.collapsed
      time = Time.now.to_f
      args.state.iterations.to_i.times do
        args.state.collapsed ||= !args.state.wave.collapse
      end
      total_time = (Time.now.to_f - time) * 1000

      args.outputs.debug << "Collapsed in #{total_time.to_sf} milliseconds @ #{args.state.iterations} iterations per tick."

      if total_time <= 16.666
        args.state.iterations += 2
      end
    end
  end
end
