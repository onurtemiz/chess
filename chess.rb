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
    p [new_x, new_y]
    @board[new_x][new_y] = @board[x][y]
    @board[x][y] = Cell.new(x, y)
    display
  end

  def is_ally?(wanted_x, wanted_y, player_color)
    @board[wanted_x][wanted_y].color == player_color
  end

  def is_valid?(x, y, player_color)
    @board[x.to_i][y.to_i].color == player_color
  end

  def play_pawn(x,y,target)
    if !@board[x][y].first_move
      @board[x][y].first_move = true
    end
    if target[0] == 7 || target[0].zero?
      if @board[x][y].color == 'white'
        @board[target[0]][target[1]] = Queen.new(target[0], target[1], 'queen', '♛', @board[x][y].color)
      else
        @board[target[0]][target[1]] = Queen.new(target[0], target[1], 'queen', '♕', @board[x][y].color)
      end
      @board[x][y] = Cell.new(x, y)
    end
  end

  def play_piece(x, y, player_color)
    target = get_user_answer(player_color, 'play', 'Hareket Ettirmek İstediğiniz Yer İçin', [x, y])
    close_possible_moves(x, y)
    if @board[x][y].type == 'pawn'
      play_pawn(x,y,target)
    else
      move_piece(x, y, target[0], target[1])
    end
    
  end

  def get_converted_answer(answer)
    letters = ('a'..'h').to_a
    y = letters.index(answer[0].downcase).to_s
    [answer[1].to_i - 1, y.to_i]
  end

  def close_possible_moves(x, y)
    @board[x][y].pos_moves.each do |pos_xy|
      @board[pos_xy[0]][pos_xy[1]].icon = @board[pos_xy[0]][pos_xy[1]].icon.no_colors
    end
    @board_class.display
  end

  def show_possible_moves(x, y)
    @board[x][y].pos_moves.each do |pos_xy|
      if @board[pos_xy[0]][pos_xy[1]].color != @board[x][y].color
        @board[pos_xy[0]][pos_xy[1]].icon = @board[pos_xy[0]][pos_xy[1]].icon.bg_red
      end
    end
    @board_class.display
  end

  def play_a_piece(player_color)
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
      p location
      if location.length == 2 && numbers.include?(location[0].to_i) && numbers.include?(location[1].to_i)
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
