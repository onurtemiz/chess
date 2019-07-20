module Moves
  def move_piece(x, y, wanted_x, wanted_y)
    @board[x][y].moved = true if @board[x][y].type == 'king' || @board[x][y].type == 'rook'
    @board[x][y].move(wanted_x, wanted_y)
    new_x = @board[x][y].x
    new_y = @board[x][y].y
    @board[new_x][new_y] = @board[x][y]
    @board[x][y] = Cell.new(x, y)
  end

  def passant_check(x,y)
    if (y-1 >= 0) && (@board[x][y-1].type == 'pawn') && (@board[x][y].color != @board[x][y-1]) && @board[x][y-1].can_killed
      p 'left'
      @board[x][y].can_passant_left = true
    end

    if (y+1 < 8) && (@board[x][y+1].type == 'pawn') && (@board[x][y].color != @board[x][y+1]) && @board[x][y+1].can_killed
      p 'right'
      @board[x][y].can_passant_right = true
    end
  end

  def play_pawn(x, y, target)

    @board[x][y].first_move = true unless @board[x][y].first_move
    @board[x][y].can_killed = true if (x-target[0]).abs == 2
    p @board[x][y].can_killed
    if target[0] == 7 || target[0].zero?
      @board[x][y].color == 'white' ? icon = '♛' : icon = '♕'
      @board[target[0]][target[1]] = Queen.new(target[0], target[1], 'queen', icon, @board[x][y].color)
      @board[x][y] = Cell.new(x, y)
    elsif @board[x][y].type == 'pawn' && (@board[x][y].can_passant_left || @board[x][y].can_passant_right)
      if @board[x][y].color == 'black' && @board[target[0]-1][target[1]].type == 'pawn' && @board[target[0]-1][target[1]].can_killed
        move_piece(x,y,target[0],target[1])
        @board[target[0]-1][target[1]] = Cell.new(target[0]-1, target[1])
      elsif @board[x][y].color == 'white' && @board[target[0]+1][target[1]].type == 'pawn' && @board[target[0]+1][target[1]].can_killed
        move_piece(x,y,target[0],target[1])
        @board[target[0]+1][target[1]] = Cell.new(target[0]+1, target[1])
      end
    else
      move_piece(x, y, target[0], target[1])
    end
  end

  def play_piece(x, y,t_x,t_y, player_color)
    player_pieces = get_player_pieces(player_color)
    player_pieces.each do |piece|
      piece.can_killed = false if piece.type == 'pawn' && piece.can_killed
    end
    @board[x][y].type == 'pawn' ? play_pawn(x, y, [t_x,t_y]) : move_piece(x, y, t_x, t_y)
  end

  def get_player_pieces(player_color)
    player_pieces = []
    @board.each_with_index do |row, x|
      row.each_with_index do |_col, y|
        player_pieces.push(@board[x][y]) if @board[x][y].color == player_color
      end
    end
    player_pieces
  end
  
  def normal_move(input,player_color)
    input = get_converted_answer(input)
    passant_check(input[0],input[1])
    show_possible_moves(input[0],input[1])
    @board_class.display
    target = get_target_piece(player_color,input)
    play_piece(input[0],input[1],target[0],target[1],player_color)
    close_possible_moves
    @board_class.display
    
  end
end