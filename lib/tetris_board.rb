# lib/tetris_board.rb
class TetrisBoard
  attr_reader :grid, :width, :height

  def self.from_state(state)
    board = new
    board.instance_variable_set(:@grid, state)
    board
  end

  def initialize(width = 10, height = 20)
    @width = width
    @height = height
    @grid = Array.new(height) { Array.new(width, nil) }
  end

  def valid_move?(piece)
    return false if piece.nil?
    piece.each_block do |x, y|
      return false if x < 0 || x >= @width || y < 0 || y >= @height
      return false if @grid[y] && @grid[y][x]
    end
    true
  end

  def lock_piece(piece)
    return if piece.nil?
    piece.each_block do |x, y|
      @grid[y][x] = piece.color if y.between?(0, @height - 1)
    end
  end

  def clear_lines
    lines_cleared = 0
    @grid.reject! do |row|
      if row.all?
        lines_cleared += 1
        true
      else
        false
      end
    end
    lines_cleared.times { @grid.unshift(Array.new(@width, nil)) }
    lines_cleared
  end
end

