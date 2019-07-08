# frozen_string_literal: true

class Cell

  attr_reader :icon, :x, :y, :color, :type
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

  def possible_up_down
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_x = 7
    until fake_x.zero?
      fake_x -= 1
      possible_moves.push([fake_x, @y]) if fake_x != @x && board[fake_x][@y].color != @color
    end
    possible_moves
  end

  def possible_right_left
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_y = 7
    until fake_y.zero?
      fake_y -= 1
      possible_moves.push([@x, fake_y]) if fake_y != @y && board[@x][fake_y].color != @color
    end
    possible_moves
  end

  def move(wanted_x, wanted_y)
    @x, @y = wanted_x, wanted_y
  end

  def possible_diag_left
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_y = @y
    fake_x = @x
    until fake_x == -1 || fake_y == -1
      fake_x -= 1
      fake_y -= 1
    end
    until fake_x == 7 || fake_y == 7
      fake_x += 1
      fake_y += 1
      possible_moves.push([fake_x, fake_y]) if (fake_x != @x && fake_y != @y) && board[fake_x][fake_y].color != @color
    end
    possible_moves
  end

  def possible_diag_right
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_y = @y
    fake_x = @x
    until fake_x == -1 || fake_y == 8
      fake_x -= 1
      fake_y += 1
    end
    until fake_x == 7 || fake_y == 0
      fake_x += 1
      fake_y -= 1
      possible_moves.push([fake_x, fake_y]) if (fake_x != @x && fake_y != @y) && board[fake_x][fake_y].color != @color
    end
    possible_moves
  end
end

class Rook < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_up_down)
    possible_moves.push(*possible_right_left)
    possible_moves
  end

  def can_move?(wanted_x, wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x, wanted_y]) ? [wanted_x, wanted_y] : nil
  end
end

class Bishop < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_diag_left)
    possible_moves.push(*possible_diag_right)
    possible_moves
  end
  
  def can_move?(wanted_x, wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x, wanted_y]) ? [wanted_x, wanted_y] : nil
  end
end

class Queen < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    possible_moves = []
    possible_moves.push(*possible_diag_left)
    possible_moves.push(*possible_diag_right)
    possible_moves.push(*possible_right_left)
    possible_moves.push(*possible_up_down)
    possible_moves
  end


  def can_move?(wanted_x,wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x,wanted_y]) ? [wanted_x,wanted_y] : nil
  end
end

class King < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    numbers = (0..7).to_a
    possible_moves = []
    possible_x_y = [[1,0],[1,-1],[1,1],[0,1],[0,-1],[-1,0],[-1,1],[-1,-1]]
    possible_x_y.each do |move|
      if numbers.include?(@x + possible_x_y[0]) && numbers.include?(@y + possible_x_y[1])
        possible_moves.push([@x+possible_x_y[0],@y+possible_x_y[1]])
      end
    end
    possible_moves
  end

  def can_move?(wanted_x,wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x,wanted_y]) ? [wanted_x,wanted_y] : nil
  end
end

class Knight < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    numbers = (0..7).to_a
    possible_moves = []
    possible_x_y = [[2, 1], [1, 2], [-2, 1], [-1, 2], [2, -1], [1, -2], [-2, -1], [-1, -2]]

    possible_x_y.each do |move|
      if numbers.include?(@x + move[0]) && numbers.include?(@y + move[1])
        possible_moves.push([@x+move[0],@y+move[1]])
      end
    end
    possible_moves
  end

  def can_move?(wanted_x, wanted_y)
    possible_moves = pos_moves
    possible_moves.include?([wanted_x,wanted_y]) ? [wanted_x,wanted_y] : nil
  end
end

class Pawn < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def pos_moves
    board = Board.class_variable_get(:@@board)
    if @color == 'white' && board[@x+1][@y].type.nil?
      return [[@x + 1, @y]] 
    elsif board[@x-1][@y].type.nil?
      return [[@x - 1, @y]]
    end
    nil
  end

  def can_move?(wanted_x,wanted_y)
    possible_moves = pos_moves
    p possible_moves
    possible_moves.include?([wanted_x,wanted_y]) ? [wanted_x,wanted_y] : nil
  end
end
