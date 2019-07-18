# frozen_string_literal: true

require './pieces'
require './board'
require './checkmate'

class String
  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def no_colors
    gsub /\e\[\d+m/, ''
  end
end

class Game
  attr_reader :board_class , :game_over
  def initialize
    @board_class = Board.new
    @board_class.display
    @board = Board.class_variable_get(:@@board)
    @game_over = false
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

  def normal_possible_moves(x,y)
    pos_moves = []
    @board[x][y].pos_moves.each do |pos_xy|
      pos_moves.push(pos_xy)
    end
    pos_moves
  end

  def king_in_check_moves(player_king)
    king_pos_moves = []
    player_king.pos_moves.each do |pos_xy|
      temp_piece = @board[pos_xy[0]][pos_xy[1]]
      temp_king = player_king
      @board[pos_xy[0]][pos_xy[1]] = player_king
      @board[temp_king.x][temp_king.y] = Cell.new(temp_king.x, temp_king.y)
      unless check?(player_king.color, pos_xy)
        @board[pos_xy[0]][pos_xy[1]] = temp_piece
        @board[temp_king.x][temp_king.y] = temp_king
        king_pos_moves.push(pos_xy)
      end
      @board[pos_xy[0]][pos_xy[1]] = temp_piece
      @board[temp_king.x][temp_king.y] = temp_king
    end
    king_pos_moves
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
            if enemy_pos_xy == player_pos_xy
              pos_moves.push(enemy_pos_xy)
            end
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
    @board_class.display
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

  def castling?(rook,king)
    if !(king.moved) && !(rook.moved) && !(check?(king.color)) && !(check?(king.color,[rook.x,rook.y])) && (rook.x == king.x) && all_empty?(rook,king)
      return true
    else
      false
    end
  end
  def castling(rook,king)
    if king.y > rook.y
      move_piece(king.x,king.y,king.x,king.y-2)
      move_piece(rook.x,rook.y,rook.x,king.y+1)
    elsif king.y < rook.y
      move_piece(king.x,king.y,king.x,king.y+2)
      move_piece(rook.x,rook.y,rook.x,king.y-1)
    end
  end

  def play_piece(x, y, player_color)
    target = get_user_answer(player_color, 'play', 'Hareket Ettirmek İstediğiniz Yer İçin', [x, y])
    close_possible_moves(x, y)
    if @board[x][y].type == 'pawn'
      play_pawn(x, y, target)
    elsif @board[x][y].type == 'king' || @board[x][y].type == 'rook'
      @board[x][y].moved = true
    else
      move_piece(x, y, target[0], target[1])
    end
    enemy_color = player_color == 'white' ? 'black' : 'white'
    if checkmate?(enemy_color) || stalemate?(enemy_color)
      @game_over = true
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

  

  def play_a_piece(player_color)
    puts 'Check!' if check?(player_color)
    answer = get_user_answer(player_color, 'pick', 'Oynayacağınız Taşı Seçmek İçin')
    unless answer == 'castling'
      show_possible_moves(answer[0], answer[1])
      play_piece(answer[0], answer[1], player_color)
    end
  end

  def get_user_answer(player_color, option, for_what, coordinats = nil)
    numbers = (0..7).to_a
    loop do
      location = ''
      puts "#{player_color.capitalize} Lütfen #{for_what} Koordinat Girin. Örnek: a8"
      input = gets.chomp.downcase
      if input.length == 14 && input[0..7] == 'castling'
        king_location = get_converted_answer(input[9..11])
        king = @board[king_location[0]][king_location[1]]
        rook_location = get_converted_answer(input[12..14])
        rook = @board[rook_location[0]][rook_location[1]]
        if rook.type == 'rook' && king.type == 'king' && castling?(rook,king)
          castling(rook,king)
          return 'castling'
        else
          next
        end
      else
        location = get_converted_answer(input)
        if location.length == 2 && numbers.include?(location[0]) && numbers.include?(location[1])
        if option == 'pick'
          if is_valid?(location[0], location[1], player_color)
            if check?(player_color)
              if @board[location[0]][location[1]].type == 'king'
                return location unless king_in_check_moves(@board[location[0]][location[1]]).length.zero?
              elsif !(piece_in_check_moves(@board[location[0]][location[1]]).length.zero?)
                return location
              else
                next
              end
            else
              return location
            end
          else
            next
          end
        elsif option == 'play'
          if @board[coordinats[0]][coordinats[1]].type == 'king'
            return location if king_in_check_moves(@board[coordinats[0]][coordinats[1]]).include?([location[0], location[1]])
          elsif check?(player_color)
            if piece_in_check_moves(@board[coordinats[0]][coordinats[1]]).include?([location[0], location[1]])
              return location
            else
              next
            end
          elsif @board[coordinats[0]][coordinats[1]].pos_moves.include?([location[0], location[1]]) && @board[coordinats[0]][coordinats[1]].type != 'king'
            return location
          else
            next
          end
        end
      end
      end
    end
  end
end

def play_again?(answer='')
  until answer == 'y' || answer == 'n'
    answer = gets.chomp.downcase
  end
  if answer == 'y'
    game = Game.new
    play_game(game)
  else
    puts 'Okay.'
  end
end

def play_game(game)
loop do
  game.play_a_piece('white')
  game.board_class.display
  if game.game_over
    break
  end
  game.play_a_piece('black')
  game.board_class.display
  if game.game_over
    break
  end
end
puts 'Game Over!'
puts 'Want to play again? (y/n)'
play_again?
end
 
game = Game.new
play_game(game)