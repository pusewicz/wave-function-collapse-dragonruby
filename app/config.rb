TILE_SIZE = 20

RULES = {
  0 => [0, 0, 0, 0],
  1 => [1, 1, 0, 1],
  2 => [1, 1, 1, 0],
  3 => [0, 1, 1, 1],
  4 => [1, 0, 1, 1],
  5 => [1, 0, 1, 0],
  6 => [0, 1, 0, 1],
  :c1 => [1, 1, 0, 0],
  :c2 => [0, 1, 1, 0],
  :c3 => [0, 0, 1, 1],
  :c4 => [1, 0, 0, 1]
}

SPRITES = {}.tap do |sprites|
  RULES.keys.map do |name|
    sprites[name] = "sprites/#{name}.png"
  end
end