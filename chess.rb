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
      unless check?(player_color, pos_xy)
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
    if check?(@board[x][y].color)
      if @board[x][y].type == 'king'
        color_pos_moves(king_in_check_moves(@board[x][y]))
      else
        color_pos_moves(piece_in_check_moves(@board[x][y]))
      end
    else
      color_pos_moves(normal_possible_moves(x,y))
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

  

  def play_a_piece(player_color)
    puts 'Check!' if checkmate?(player_color)
    answer = get_user_answer(player_color, 'pick', 'Oynayacağınız Taşı Seçmek İçin')
    show_possible_moves(answer[0], answer[1])
    play_piece(answer[0], answer[1], player_color)
  end

  def get_user_answer(player_color, option, for_what, coordinats = nil)
    numbers = (0..7).to_a
    loop do
      if checkmate?(player_color)
        @game_over = true
        break
      end
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
          if check?(player_color)
            if @board[coordinats[0]][coordinats[1]].type == 'king'
              return location if king_in_check_moves(@board[coordinats[0]][coordinats[1]]).include?([location[0], location[1]])
            elsif piece_in_check_moves(@board[coordinats[0]][coordinats[1]]).include?([location[0], location[1]])
              return location
            end
          elsif @board[coordinats[0]][coordinats[1]].pos_moves.include?([location[0], location[1]])
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
  if game.game_over
    break
  end
  game.play_a_piece('black')
  game.board_class.display
  if game.game_over
    break
  end
end
