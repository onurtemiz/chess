# frozen_string_literal: true

require './pieces'
require './board'

class String
  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def no_colors
    gsub /\e\[\d+m/, ''
  end
end

class Game
  attr_reader :board_class
  def initialize
    @board_class = Board.new
    @board_class.display
    @board = Board.class_variable_get(:@@board)
  end

  def move_piece(x, y, wanted_x, wanted_y)
    @board[x][y].move(wanted_x, wanted_y)
    new_x = @board[x][y].x
    new_y = @board[x][y].y
    @board[new_x][new_y] = @board[x][y]
    @board[x][y] = Cell.new(x, y)
  end

  def is_ally?(wanted_x, wanted_y, player_color)
    @board[wanted_x][wanted_y].color == player_color
  end

  def is_valid?(x, y, player_color)
    @board[x][y].color == player_color && @board[x][y].pos_moves.length.positive? ? true : false
  end

  def play_pawn(x, y, target)
    @board[x][y].first_move = true unless @board[x][y].first_move
    if target[0] == 7 || target[0].zero?
      if @board[x][y].color == 'white'
        @board[target[0]][target[1]] = Queen.new(target[0], target[1], 'queen', '♛', @board[x][y].color)
      else
        @board[target[0]][target[1]] = Queen.new(target[0], target[1], 'queen', '♕', @board[x][y].color)
      end
      @board[x][y] = Cell.new(x, y)
    else
      move_piece(x, y, target[0], target[1])
    end
  end

  def close_possible_moves(x, y)
    @board[x][y].pos_moves.each do |pos_xy|
      @board[pos_xy[0]][pos_xy[1]].icon = @board[pos_xy[0]][pos_xy[1]].icon.no_colors
    end
    @board_class.display
  end

  def show_possible_moves(x, y)
    @board[x][y].pos_moves.each do |pos_xy|
      @board[pos_xy[0]][pos_xy[1]].icon = @board[pos_xy[0]][pos_xy[1]].icon.bg_red
    end
    @board_class.display
  end

  def play_piece(x, y, player_color)
    target = get_user_answer(player_color, 'play', 'Hareket Ettirmek İstediğiniz Yer İçin', [x, y])
    close_possible_moves(x, y)
    if @board[x][y].type == 'pawn'
      play_pawn(x, y, target)
    else
      move_piece(x, y, target[0], target[1])
    end
  end

  def get_converted_answer(answer)
    letters = ('a'..'h').to_a
    y = letters.index(answer[0].downcase).to_s
    [answer[1].to_i - 1, y.to_i]
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

  def get_king(player_color)
    player_pieces = get_player_pieces(player_color)
    player_pieces.each do |piece|
      return piece if piece.type == 'king'
    end
  end

  def is_check?(player_color, king_location)
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
      temp_king = player_king
      @board[pos_xy[0]][pos_xy[1]] = player_king
      @board[temp_king.x][temp_king.y] = Cell.new(temp_king.x, temp_king.y)
      unless is_check?(player_color, pos_xy)
        @board[pos_xy[0]][pos_xy[1]] = temp_piece
        @board[temp_king.x][temp_king.y] = temp_king
        return true
      end
      @board[pos_xy[0]][pos_xy[1]] = temp_piece
      @board[temp_king.x][temp_king.y] = temp_king
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
        target_pieces.push(piece) if pos_xy == [player_king.x,player_king.y]
      end
    end
    target_pieces
  end

  def can_kill_piece?(player_color)
    player_pieces = get_player_pieces(player_color)
    target_pieces = get_enemy_checking_pieces(player_color)
    player_pieces.each do |piece|
      next if piece.type == 'king'
      piece.pos_moves.each do |pos_xy|
        target_pieces.each do |target_piece|
          if pos_xy == [target_piece.x,target_piece.y]
            target_pieces.delete(target_piece)
            break
          end
        end
      end
    end
    target_pieces.length.zero? ? true : false
  end

  def verhor_locations_between_king(piece,king)
    locations = []
    if piece.type == 'rook' || piece.type == 'queen'
      if piece.x == king.x
        fake_y = piece.y
        if piece.y > king.y + 1
          until fake_y == king.y+1
            fake_y -= 1
            locations.push([piece.x,fake_y])
          end
        elsif piece.y < king.y - 1
          until fake_y == king.y-1
            fake_y += 1
            locations.push([piece.x,fake_y])
          end
        end
      else
        fake_x = piece.x
        if piece.x > king.x + 1
          until fake_x == king.x+1
            fake_x -= 1
            locations.push([fake_x,piece.y])
          end
        elsif piece.x < king.x-1
          until fake_x == king.x-1
            fake_x += 1
            locations.push([fake_x,piece.y])
          end
        end
      end
    end    
    locations
  end

  def diag_locations_between_king(piece,king)
    if piece.type == 'bishop' || piece.type == 'queen'
      fake_x = piece.x
      fake_y = piece.y
      locations = []
      if fake_x > king.x && fake_y < king.y
        until fake_x.zero? || fake_y == 7
          fake_x -= 1
          fake_y += 1
          locations.push([fake_x,fake_y])
          return locations if fake_x == king.x+1 && fake_y == king.y-1
        end
      elsif fake_x > king.x && fake_y > king.y
        until fake_x.zero? || fake_y.zero?
          fake_x -= 1
          fake_y -= 1
          locations.push([fake_x,fake_y])
          return locations if fake_x == king.x+1 && fake_y == king.y+1
        end
      elsif fake_x < king.x && fake_y > king.y
        until fake_x == 7 || fake_y.zero?
          fake_x += 1
          fake_y -= 1
          locations.push([fake_x,fake_y])
          return locations if fake_x == king.x-1 && fake_y == king.y+1
        end
      elsif fake_x < king.x && fake_y < king.y
        until fake_x == 7 || fake_y == 7
          fake_x += 1
          fake_y += 1
          locations.push([fake_x,fake_y])
          return locations if fake_x == king.x-1 && fake_y == king.y-1
        end
      end
    end
  end


  def locations_between_king(piece,king)
    locations = []
    locations.push(*diag_locations_between_king(piece,king))
    locations.push(*verhor_locations_between_king(piece,king))
    locations
  end

  def can_move_between?(player_color)
    enemy_pieces = get_enemy_checking_pieces(player_color)
    player_pieces = get_player_pieces(player_color)
    player_king = get_king(player_color)
    enemy_pieces.each do |enemy_piece|
      enemy_pos = locations_between_king(enemy_piece,player_king)
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

  def is_checkmate?(player_color)
    king = get_king(player_color)
    if is_check?(player_color,[king.x,king.y])
      if can_king_move?(player_color)
        p 'can move'
        return false
      elsif can_kill_piece?(player_color)
        p 'can kill'
        return false
      elsif can_move_between?(player_color)
        p 'can move between'
        return false
      end
      return true
    end
    
  end

  def play_a_piece(player_color)
    puts 'Check!' if is_checkmate?(player_color)
    answer = get_user_answer(player_color, 'pick', 'Oynayacağınız Taşı Seçmek İçin')
    show_possible_moves(answer[0], answer[1])
    play_piece(answer[0], answer[1], player_color)
  end

  def get_user_answer(player_color, option, for_what, coordinats = nil)
    numbers = (0..7).to_a
    loop do
      location = ''
      puts "#{player_color.capitalize} Lütfen #{for_what} Koordinat Girin. Örnek: a8"
      location = get_converted_answer(gets.chomp.downcase)
      if location.length == 2 && numbers.include?(location[0]) && numbers.include?(location[1])
        if option == 'pick'
          if is_valid?(location[0], location[1], player_color)
            return location
          else
            next
          end
        elsif option == 'play'
          if @board[coordinats[0]][coordinats[1]].pos_moves.include?([location[0], location[1]])
            return location
          else
            next
          end
        end
      end
    end
  end
end

game = Game.new

loop do
  game.play_a_piece('white')
  game.board_class.display
  game.play_a_piece('black')
  game.board_class.display
end
