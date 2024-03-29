require_relative "config"
require_relative "tile"
require_relative "cell"
require_relative "grid"

def tick(args)
  if args.state.tick_count == 0
    args.outputs.debug << "Initializing..."
    args.state.options = RULES.map do |name, edges|
      Tile.new(name, edges)
    end

    args.state.options.each do |tile|
      tile.rules = args.state.options
    end

    args.state.collapsed = false

    args.state.wave = Grid.new(args.grid.w.div(TILE_SIZE), args.grid.h.div(TILE_SIZE), args.state.options)
    args.state.paused = true
    args.outputs.debug << "Initialized!"
  else
    args.outputs.debug << "FPS: #{args.gtk.current_framerate.to_sf}"
    if args.inputs.keyboard.key_down.space
      args.state.paused = !args.state.paused
    end
    args.state.start_time ||= Time.now
    args.state.wave.grid.each do |col|
      col.each do |cell|
        if cell.name
          args.outputs.sprites << {
            x: cell.x * TILE_SIZE,
            y: cell.y * TILE_SIZE,
            w: TILE_SIZE,
            h: TILE_SIZE,
            path: SPRITES[cell.name]
          }.sprite!
        else
          args.outputs.borders << {
            x: cell.x * TILE_SIZE,
            y: cell.y * TILE_SIZE,
            w: TILE_SIZE,
            h: TILE_SIZE,
            r: 0,
            g: 128,
            b: 0,
            a: 128
          }
          args.outputs.labels << {
            x: cell.x * TILE_SIZE + TILE_SIZE.div(2), 
            y: cell.y * TILE_SIZE + TILE_SIZE.div(2) - 1,
            text: cell.entropy.to_s,
            size_enum: -4,
            alignment_enum: 1,
            vertical_alignment_enum: 1
          }.merge(cell.entropy < args.state.options.size ? { r: 0, g: 0, b: 255 } : {}).label!
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
      args.outputs.debug << "Collapsed! Took #{(args.state.end_time - args.state.start_time).to_sf} seconds."
    end
    args.outputs.debug << "Paused. Press SPACE to resume." if args.state.paused
    if !args.state.paused && !args.state.collapsed
      time = Time.now
      args.state.collapsed ||= !args.state.wave.collapse
      args.outputs.debug << "Collapsed in #{(Time.now - time).to_sf} seconds."
    end
  end
end
