# frozen_string_literal: true

require './pieces'
require './board'
require './checkmate'
require './castling'
require './input_validation'
require './show_moves'
require './moves'
require './ai'

class String
  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def no_colors
    gsub /\e\[\d+m/, ''
  end
end

class Game
  include CheckMate
  include Castling
  include InputValidation
  include ShowMoves
  include Moves
  include AI
  attr_reader :board_class , :game_over
  def initialize
    @board_class = Board.new
    @board_class.display
    @board = Board.class_variable_get(:@@board)
    @game_over = false
    @repetition = 0
  end


  
  
  def get_pieces(board)
    board_pieces = []
    board.each_with_index do |row,row_index|
      row.each_with_index do |col,col_index|
        if !(board[row_index][col_index].type.nil?)
          board_pieces.push(board[row_index][col_index])
        end
      end
    end
    board_pieces
  end


  def get_pawns_locations(board)
    locations = []
    board.each_with_index do |r, row|
      r.each_with_index do |_c, col|
        locations.push([row,col]) if board[row][col].type == 'pawn'
      end
    end
    locations
  end

  def no_pawn_move?(old_pawns,new_pawns)
    new_pawns.each do |new_location|
      old_pawns.delete(new_location) if old_pawns.include?(new_location)
    end
    old_pawns.length.zero? ? true : false
  end


  def repetition?(old_pieces,old_pawns,new_pieces,new_pawns)
    old_pieces.length == new_pieces.length && no_pawn_move?(old_pawns,new_pawns) ? @repetition += 1 : @repetition = 0
  end

  def game_over?(player_color)
    enemy_color = player_color == 'white' ? 'black' : 'white'
    @game_over = true if checkmate?(enemy_color) || stalemate?(enemy_color) || @repetition == 50
  end

end

def play_again?(answer='')
  until answer == 'y' || answer == 'n'
    answer = gets.chomp.downcase
  end
  play_game() if  answer == 'y'
end

def get_player_or_ai(answer='')
  until answer == 'ai' || answer == 'player'
    answer = gets.chomp.downcase
  end
  answer
end

def player_plays(player,player_color,game)
  player == 'player' ? game.decide_user_input(player_color) : game.ai_play_piece(player_color)
  game.board_class.display
end

def play_game()
  game = Game.new
  puts 'Player 1: AI Or Player?'
  player1 = get_player_or_ai()
  puts 'Player 2: AI Or Player?'
  player2 = get_player_or_ai()


loop do
  player_plays(player1,'white',game)
  break if game.game_over
  player_plays(player2,'black',game)
  break if game.game_over
end
puts 'Game Over!'
puts 'Do you want to play again? (y/n)'
play_again?
end
 
play_game()