require './pieces'
require './board'

board = Board.new

board.display

board.ask_to_move('white')

board.display