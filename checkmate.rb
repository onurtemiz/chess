# frozen_string_literal: true
module CheckMate
def get_king(player_color)
  player_pieces = get_player_pieces(player_color)
  player_pieces.each do |piece|
    return piece if piece.type == 'king'
  end
end

def piece_eats_enemy(piece)
  pos_moves = []
  target_pieces = get_enemy_checking_pieces(piece.color)
    piece.pos_moves.each do |pos_xy|
      target_pieces.each do |target_piece|
        if pos_xy == [target_piece.x,target_piece.y]
          pos_moves.push(pos_xy)
        end
      end
    end
  pos_moves
end

def piece_between_enemy(piece)
  pos_moves = []
  enemy_pieces = get_enemy_checking_pieces(piece.color)
  player_king = get_king(piece.color)
  enemy_pieces.each do |enemy_piece|
    enemy_pos = locations_between_king(enemy_piece,player_king)
    enemy_pos.each do |enemy_pos_xy|
        piece.pos_moves.each do |player_pos_xy|
          pos_moves.push(enemy_pos_xy) if enemy_pos_xy == player_pos_xy
        end
    end
  end
  pos_moves
end

def piece_in_check_moves(piece)
  pos_moves = []
  pos_moves.push(*piece_eats_enemy(piece))
  pos_moves.push(*piece_between_enemy(piece))
  pos_moves
end

def king_in_check_moves(player_king)
  king_pos_moves = []
  player_king.pos_moves.each do |pos_xy|
    temp_piece = @board[pos_xy[0]][pos_xy[1]]
    @board[pos_xy[0]][pos_xy[1]] = player_king
    @board[player_king.x][player_king.y] = Cell.new(player_king.x, player_king.y)
    unless check?(player_king.color, pos_xy)
      @board[pos_xy[0]][pos_xy[1]] = temp_piece
      @board[player_king.x][player_king.y] = player_king
      king_pos_moves.push(pos_xy)
    end
    @board[pos_xy[0]][pos_xy[1]] = temp_piece
    @board[player_king.x][player_king.y] = player_king
  end
  king_pos_moves
end


def get_king_pos_xy(player_color)
  king = get_king(player_color)
  [king.x, king.y]
end

def check?(player_color, king_location = get_king_pos_xy(player_color))
  enemy_color = player_color == 'white' ? 'black' : 'white'
  enemy_pieces = get_player_pieces(enemy_color)
  enemy_pieces.each do |piece|
    piece.pos_moves.each do |pos_xy|
      return true if pos_xy == king_location
    end
  end
  false
end

def can_king_move?(player_color)
  player_king = get_king(player_color)
  player_king.pos_moves.each do |pos_xy|
    temp_piece = @board[pos_xy[0]][pos_xy[1]]
    @board[pos_xy[0]][pos_xy[1]] = player_king
    @board[player_king.x][player_king.y] = Cell.new(player_king.x, player_king.y)
    unless check?(player_color, pos_xy)
      @board[pos_xy[0]][pos_xy[1]] = temp_piece
      @board[player_king.x][player_king.y] = player_king
      return true
    end
    @board[pos_xy[0]][pos_xy[1]] = temp_piece
    @board[player_king.x][player_king.y] = player_king
  end
  false
end

def get_enemy_checking_pieces(player_color)
  target_pieces = []
  player_king = get_king(player_color)
  enemy_color = player_color == 'white' ? 'black' : 'white'
  enemy_pieces = get_player_pieces(enemy_color)
  enemy_pieces.each do |piece|
    piece.pos_moves.each do |pos_xy|
      target_pieces.push(piece) if pos_xy == [player_king.x, player_king.y]
    end
  end
  target_pieces
end

def can_kill_piece?(player_color)
  player_pieces = get_player_pieces(player_color)
  target_pieces = get_enemy_checking_pieces(player_color)
  return false if target_pieces.length > 1

  player_pieces.each do |piece|
    next if piece.type == 'king'

    piece.pos_moves.each do |pos_xy|
      target_pieces.each do |target_piece|
        if pos_xy == [target_piece.x, target_piece.y]
          target_pieces.delete(target_piece)
          break
        end
      end
    end
  end
  target_pieces.length.zero? ? true : false
end

def verhor_locations_between_king(piece, king)
  locations = []
  if piece.type == 'rook' || piece.type == 'queen'
    if piece.x == king.x
      fake_y = piece.y
      if piece.y > king.y + 1
        until fake_y == king.y + 1
          fake_y -= 1
          locations.push([piece.x, fake_y])
        end
      elsif piece.y < king.y - 1
        until fake_y == king.y - 1
          fake_y += 1
          locations.push([piece.x, fake_y])
        end
      end
    elsif piece.y == king.y
      fake_x = piece.x
      if piece.x > king.x + 1
        until fake_x == king.x + 1
          fake_x -= 1
          locations.push([fake_x, piece.y])
        end
      elsif piece.x < king.x - 1
        until fake_x == king.x - 1
          fake_x += 1
          locations.push([fake_x, piece.y])
        end
      end
    end
  end
  locations
end

def diag_locations_between_king(piece, king)
  if piece.type == 'bishop' || piece.type == 'queen'
    fake_x = piece.x
    fake_y = piece.y
    locations = []
    if fake_x > king.x && fake_y < king.y
      until fake_x.zero? || fake_y == 7
        fake_x -= 1
        fake_y += 1
        locations.push([fake_x, fake_y])
        return locations if fake_x == king.x + 1 && fake_y == king.y - 1
      end
    elsif fake_x > king.x && fake_y > king.y
      until fake_x.zero? || fake_y.zero?
        fake_x -= 1
        fake_y -= 1
        locations.push([fake_x, fake_y])
        return locations if fake_x == king.x + 1 && fake_y == king.y + 1
      end
    elsif fake_x < king.x && fake_y > king.y
      until fake_x == 7 || fake_y.zero?
        fake_x += 1
        fake_y -= 1
        locations.push([fake_x, fake_y])
        return locations if fake_x == king.x - 1 && fake_y == king.y + 1
      end
    elsif fake_x < king.x && fake_y < king.y
      until fake_x == 7 || fake_y == 7
        fake_x += 1
        fake_y += 1
        locations.push([fake_x, fake_y])
        return locations if fake_x == king.x - 1 && fake_y == king.y - 1
      end
    end
  end
end

def locations_between_king(piece, king)
  locations = []
  locations.push(*diag_locations_between_king(piece, king))
  locations.push(*verhor_locations_between_king(piece, king))
  locations
end

def can_move_between?(player_color)
  enemy_pieces = get_enemy_checking_pieces(player_color)
  return false if enemy_pieces.length > 1

  player_pieces = get_player_pieces(player_color)
  player_king = get_king(player_color)
  enemy_pieces.each do |enemy_piece|
    enemy_pos = locations_between_king(enemy_piece, player_king)
    enemy_pos.each do |enemy_pos_xy|
      player_pieces.each do |player_piece|
        next if player_piece.type == 'king'

        player_piece.pos_moves.each do |player_pos_xy|
          if enemy_pos_xy == player_pos_xy
            enemy_pieces.delete(enemy_piece)
            break
          end
        end
      end
    end
  end
  enemy_pieces.length.zero? ? true : false
end

def checkmate?(player_color)
  if check?(player_color)
    return false if can_king_move?(player_color) || can_kill_piece?(player_color) || can_move_between?(player_color)

    true
  end
end

def stalemate?(player_color)
  unless check?(player_color)
    stalemate = true
    player_pieces = get_player_pieces(player_color)
    player_pieces.each do |piece|
      if piece.type == 'king'
        king_in_check_moves(piece).each do |pos_xy|
          stalemate = false unless pos_xy.length.zero?
        end
      else
        piece.pos_moves.each do |pos_xy|
          stalemate = false unless pos_xy.length.zero?
        end
      end
    end
    return stalemate
  end
  false
end
end