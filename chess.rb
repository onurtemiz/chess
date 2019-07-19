# frozen_string_literal: true

require './pieces'
require './board'
require './checkmate'
require './castling'
require './input_validation'
require './show_moves'
require './moves'

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
  attr_reader :board_class , :game_over
  def initialize
    @board_class = Board.new
    @board_class.display
    @board = Board.class_variable_get(:@@board)
    @game_over = false
  end

  def game_over?(player_color)
    enemy_color = player_color == 'white' ? 'black' : 'white'
    @game_over = true if checkmate?(enemy_color) || stalemate?(enemy_color)
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
  game.decide_user_input('white')
  game.board_class.display
  break if game.game_over

  game.decide_user_input('black')
  game.board_class.display
  break if game.game_over
end
puts 'Game Over!'
puts 'Do you want to play again? (y/n)'
play_again?
end
 
game = Game.new
play_game(game)