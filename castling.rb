module Castling
  def castling?(rook,king)
    king.y > rook.y ? cast = -2 : cast = +2

    !(king.moved) && !(rook.moved) && !(check?(king.color)) && !(check?(king.color,[king.x,king.y+cast])) && (rook.x == king.x) && all_empty?(rook,king) ? true : false
  end

  def castling(input)
    rook,king = get_rook_king_by_input(input)
    if king.y > rook.y
      move_piece(king.x,king.y,king.x,king.y-2)
      move_piece(rook.x,rook.y,rook.x,king.y+1)
    elsif king.y < rook.y
      move_piece(king.x,king.y,king.x,king.y+2)
      move_piece(rook.x,rook.y,rook.x,king.y-1)
    end
  end

  def all_empty?(rook,king)
    all_empty = true
    fake_y = rook.y
    if rook.y > king.y
      until fake_y == king.y+1
        fake_y -= 1
        unless @board[rook.x][fake_y].type.nil?
          all_empty = false
        end
      end
    elsif rook.y < king.y
      until fake_y == king.y-1
        fake_y += 1
        unless @board[rook.x][fake_y].type.nil?
          all_empty = false
        end
      end
    end
    all_empty
  end
end