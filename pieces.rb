# frozen_string_literal: true

require './move_modules'

class Cell
  attr_accessor :icon
  attr_reader :x, :y, :color, :type
  def initialize(x, y, type = nil, icon = ' ', color = nil)
    @x = x
    @y = y
    @type = type
    @icon = icon
    @color = color
  end

  def to_s
    @icon
  end

  def move(wanted_x, wanted_y)
    @x = wanted_x
    @y = wanted_y
  end

  def can_move?(wanted_x, wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x, wanted_y]) ? [wanted_x, wanted_y] : nil
  end
end

class Rook < Cell
  include VerHorMove

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_up_down)
    possible_moves.push(*possible_right_left)
    possible_moves
  end
end

class Bishop < Cell
  include DiagonalMove

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_diag_left)
    possible_moves.push(*possible_diag_right)
    possible_moves
  end
end

class Queen < Cell
  include VerHorMove
  include DiagonalMove

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_diag_left)
    possible_moves.push(*possible_diag_right)
    possible_moves.push(*possible_right_left)
    possible_moves.push(*possible_up_down)
    possible_moves
  end
end

class King < Cell
  def pos_moves
    board = Board.class_variable_get(:@@board)
    numbers = (0..7).to_a
    possible_moves = []
    possible_x_y = [[1, 0], [1, -1], [1, 1], [0, 1], [0, -1], [-1, 0], [-1, 1], [-1, -1]]
    possible_x_y.each do |move|
      if numbers.include?(@x + move[0]) && numbers.include?(@y + move[1])
        possible_moves.push([@x + move[0], @y + move[1]]) if board[@x + move[0]][@y + move[1]].color != @color
      end
    end
    possible_moves
  end
end

class Knight < Cell
  def pos_moves
    board = Board.class_variable_get(:@@board)
    numbers = (0..7).to_a
    possible_moves = []
    possible_x_y = [[2, 1], [1, 2], [-2, 1], [-1, 2], [2, -1], [1, -2], [-2, -1], [-1, -2]]
    possible_x_y.each do |move|
      if numbers.include?(@x + move[0]) && numbers.include?(@y + move[1])
        possible_moves.push([@x + move[0], @y + move[1]])
      end
    end
    possible_moves
  end
end

class Pawn < Cell
  attr_accessor :first_move
  def initialize(x, y, type, icon, color)
    super
    @first_move = false
  end

  def pos_moves
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    if @color == 'black'
      possible_moves.push([@x + 1, @y]) if board[@x+1][@y].type.nil?
      possible_moves.push([@x + 2, @y]) if !@first_move && board[@x+2][@y].type.nil? 
      possible_moves.push([@x + 1,@y - 1]) if @y != 0 && !(board[@x+1][@y-1].type.nil?)
      possible_moves.push([@x + 1,@y + 1]) if @y != 7 && !(board[@x+1][@y+1].type.nil?)
    else
      possible_moves.push([@x - 1, @y]) if board[@x-1][@y].type.nil?
      possible_moves.push([@x - 2, @y]) if !@first_move && board[x-2][@y].type.nil?
      possible_moves.push([@x - 1,@y - 1]) if @y != 0 && !(board[@x-1][@y-1].type.nil?) 
      possible_moves.push([@x - 1,@y + 1]) if @y != 7 && !(board[@x-1][@y+1].type.nil?) 
    end
    possible_moves
  end
end
