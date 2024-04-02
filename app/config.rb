class Config
  TILE_SIZE = 20

  RULES = {
    0 => { edges: [0, 0, 0, 0], probability: 1.0 },
    1 => { edges: [1, 1, 0, 1], probability: 1.0 },
    2 => { edges: [1, 1, 1, 0], probability: 1.0 },
    3 => { edges: [0, 1, 1, 1], probability: 1.0 },
    4 => { edges: [1, 0, 1, 1], probability: 1.0 },
    5 => { edges: [1, 0, 1, 0], probability: 1.0 },
    6 => { edges: [0, 1, 0, 1], probability: 1.0 },
    :c1 => { edges: [1, 1, 0, 0], probability: 1.0 },
    :c2 => { edges: [0, 1, 1, 0], probability: 1.0 },
    :c3 => { edges: [0, 0, 1, 1], probability: 1.0 },
    :c4 => { edges: [1, 0, 0, 1], probability: 1.0 },
    :e1 => { edges: [0, 0, 0, 1], probability: 0.1 },
    :e2 => { edges: [1, 0, 0, 0], probability: 0.1 },
    :e3 => { edges: [0, 1, 0, 0], probability: 0.1 },
    :e4 => { edges: [0, 0, 1, 0], probability: 0.1 },
    :cross => { edges: [1, 1, 1, 1], probability: 0.5 }
  }.freeze

  SPRITES = {}.tap do |sprites|
    RULES.keys.map do |name|
      sprites[name] = "sprites/#{name}.png"
    end
  end
end
