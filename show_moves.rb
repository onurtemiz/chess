module ShowMoves
  
  def close_possible_moves()
    @board.each_with_index do |row,r|
      row.each_with_index do |col,c|
        @board[r][c].icon = @board[r][c].icon.no_colors
      end
    end
  end

  def color_pos_moves(array)
    array.each do |pos_xy|
      @board[pos_xy[0]][pos_xy[1]].icon = @board[pos_xy[0]][pos_xy[1]].icon.bg_red
    end
  end

  def show_possible_moves(x, y)
    if @board[x][y].type == 'king'
      color_pos_moves(king_in_check_moves(@board[x][y]))
    elsif check?(@board[x][y].color)
        color_pos_moves(piece_in_check_moves(@board[x][y]))
    else
      color_pos_moves(normal_possible_moves(x,y))
    end
  end
  
  def normal_possible_moves(x,y)
    pos_moves = []
    @board[x][y].pos_moves.each do |pos_xy|
      pos_moves.push(pos_xy)
    end
    pos_moves
  end

end