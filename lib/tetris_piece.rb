# lib/tetris_piece.rb
class TetrisPiece
  SHAPES = {
    I: [[0x0F00], [0x2222], [0x00F0], [0x4444]], J: [[0x44C0], [0x8E00], [0x6440], [0x0E20]],
    L: [[0x4460], [0x0E80], [0xC440], [0x2E00]], O: [[0x6600], [0x6600], [0x6600], [0x6600]],
    S: [[0x06C0], [0x8C40], [0x6C00], [0x4620]], Z: [[0x0C60], [0x4C80], [0xC600], [0x2640]],
    T: [[0x0E40], [0x4C40], [0x4E00], [0x4640]]
  }.freeze
  COLORS = { I: '#00f0f0', J: '#0000f0', L: '#f0a000', O: '#f0f000', S: '#00f000', Z: '#f00000', T: '#a000f0' }.freeze
  attr_reader :type, :color, :x, :y, :rotation

  def self.from_state(state)
    return nil if state.nil?
    piece = new(state['type'].to_sym, state['x'], state['y'])
    piece.instance_variable_set(:@rotation, state['rotation'])
    piece
  end

  def initialize(type, x, y)
    @type = type
    @color = COLORS[type]
    @x = x
    @y = y
    @rotation = 0
  end

  def to_state
    { 'type' => @type, 'x' => @x, 'y' => @y, 'rotation' => @rotation }
  end
  
  def move(dx, dy); @x += dx; @y += dy; end
  def rotate; @rotation = (@rotation + 1) % 4; end
  def undo_rotate; @rotation = (@rotation - 1 + 4) % 4; end

  def each_block
    shape = SHAPES[@type][@rotation].first
    (0..15).each do |i|
      if (shape >> i) & 1 == 1
        yield(@x + (i % 4), @y + (i / 4))
      end
    end
  end
end

