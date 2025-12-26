# lib/tetris_game.rb
require_relative 'tetris_board'
require_relative 'tetris_piece'

class TetrisGame
  attr_reader :score, :level, :lines_cleared, :game_over

  def self.from_state(state)
    new(state: state)
  end

  def initialize(state: nil)
    if state
      @board = TetrisBoard.from_state(state['grid'])
      @current_piece = TetrisPiece.from_state(state['current_piece_state'])
      @score = state['score']
      @level = state['level']
      @lines_cleared = state['lines_cleared']
      @game_over = state['game_over']
    else
      @board = TetrisBoard.new
      @score = 0
      @level = 1
      @lines_cleared = 0
      @game_over = false
      spawn_piece
    end
  end

  def handle_action(action)
    return if @game_over
    case action
    when 'left'  then move_left
    when 'right' then move_right
    when 'down'  then move_down
    when 'rotate'then rotate
    when 'drop'  then hard_drop
    end
  end

  def state_for_session
    {
      'grid' => @board.grid,
      'current_piece_state' => @current_piece&.to_state,
      'score' => @score,
      'level' => @level,
      'lines_cleared' => @lines_cleared,
      'game_over' => @game_over
    }
  end

  def state_for_client
    client_piece = nil
    if @current_piece
      blocks = []
      @current_piece.each_block { |x, y| blocks << {x: x, y: y} }
      client_piece = { color: @current_piece.color, blocks: blocks }
    end
    state_for_session.merge(
      current_piece: client_piece,
      lines: @lines_cleared,
      fall_speed: fall_speed
    )
  end

  private

  def spawn_piece
    @current_piece = TetrisPiece.new(TetrisPiece::SHAPES.keys.sample, 3, 0)
    if !@board.valid_move?(@current_piece)
      @game_over = true
      @current_piece = nil
    end
  end

  def move_down
    return if @current_piece.nil?
    @current_piece.move(0, 1)
    unless @board.valid_move?(@current_piece)
      @current_piece.move(0, -1)
      @board.lock_piece(@current_piece)
      cleared = @board.clear_lines
      update_score(cleared)
      spawn_piece
    end
  end

  def move_left
    return if @current_piece.nil?
    @current_piece.move(-1, 0)
    @current_piece.move(1, 0) unless @board.valid_move?(@current_piece)
  end

  def move_right
    return if @current_piece.nil?
    @current_piece.move(1, 0)
    @current_piece.move(-1, 0) unless @board.valid_move?(@current_piece)
  end

  def rotate
    return if @current_piece.nil?
    @current_piece.rotate
    @current_piece.undo_rotate unless @board.valid_move?(@current_piece)
  end

  def hard_drop
    return if @current_piece.nil?
    @current_piece.move(0, 1) while @board.valid_move?(@current_piece)
    @current_piece.move(0, -1)
    move_down
  end

  def update_score(lines)
    return if lines == 0
    points = { 1 => 100, 2 => 300, 3 => 500, 4 => 800 }
    @score += (points[lines] || 0) * @level
    @lines_cleared += lines
    @level = (@lines_cleared / 10) + 1
  end

  def fall_speed
    [800 - (@level * 50), 50].max
  end
end

