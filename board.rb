# frozen_string_literal: true

require './pieces'

class Board
  attr_reader :board
  def initialize
    @@board = Array.new(8) { Array.new(8) }
    initialize_pieces('black')
    initialize_pieces('white')

    @@board.each_with_index do |r, row|
      r.each_with_index do |_c, col|
        @@board[row][col] = Cell.new(row, col) if @@board[row][col].nil?
      end
    end
  end

  def initialize_pieces(color, r = '♖', k = '♘', pi = '♙', ki = '♔', q = '♕', b = '♗', piece_row = 0, pawn_row = 1)
    if color == 'white'
      piece_row = 7
      pawn_row = 6
      r = '♜'
      k = '♞'
      pi = '♟'
      ki = '♚'
      q = '♛'
      b = '♝'
    end
    @@board[piece_row][0] = Rook.new(piece_row, 0, 'rook', r, color)
    @@board[piece_row][7] = Rook.new(piece_row, 7, 'rook', r, color)
    # @@board[piece_row][1] = Knight.new(piece_row, 1, 'knight', k, color)
    # @@board[piece_row][6] = Knight.new(piece_row, 6, 'knight', k, color)
    # @@board[piece_row][2] = Bishop.new(piece_row, 2, 'bishop', b, color)
    # @@board[piece_row][5] = Bishop.new(piece_row, 5, 'bishop', b, color)
    # @@board[piece_row][3] = Queen.new(piece_row, 3, 'queen', q, color)
    @@board[piece_row][4] = King.new(piece_row, 4, 'king', ki, color)
    @@board[pawn_row].each_with_index do |_pawn, index|
      @@board[pawn_row][index] = Pawn.new(pawn_row, index, 'pawn', pi, color)
    end
  end

  def display
    puts ' ┏━┳━┳━┳━┳━┳━┳━┳━┓'
    @@board.each_with_index do |row, index|
      puts "#{index + 1}┃" + row.join('┃') + '┃'
      puts ' ┣━╋━╋━╋━╋━╋━╋━╋━┫' if index != @@board.length - 1
    end
    puts ' ┗━┻━┻━┻━┻━┻━┻━┻━┛'
    puts '  A B C D E F G H'
  end
end
