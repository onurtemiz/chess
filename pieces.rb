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
end

class Rook < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def possible_up_down(up_down)
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_x = @x
    limit = if up_down == -1
              0
            else
              7
            end
    until fake_x == limit
      fake_x += up_down
      possible_moves.push([fake_x, @y]) if board[fake_x][@y].color != @color
    end
    possible_moves
  end

  def possible_right_left(right_left)
    board = Board.class_variable_get(:@@board)
    possible_moves = []
    fake_y = @y
    limit = if right_left == -1
              0
            else
              7
            end
    until fake_y == limit
      fake_y += right_left
      possible_moves.push([@x, fake_y]) if board[@x][fake_y].color != @color
    end
    possible_moves
  end

  def can_move?(wanted_x, wanted_y)
    possible_moves = []
    possible_moves.push(*possible_up_down(-1))
    possible_moves.push(*possible_up_down(1))
    possible_moves.push(*possible_right_left(-1))
    possible_moves.push(*possible_right_left(1))
    return [wanted_x, wanted_y] if possible_moves.include?([wanted_x, wanted_y])
    nil
  end

  def move(wanted_x, wanted_y)
    @x,@y = can_move?(wanted_x,wanted_y)
  end
end

class Bishop < Cell
  def initialize(x, y, type, icon, color)
    super
  end
end

class Queen < Cell
  def initialize(x, y, type, icon, color)
    super
  end
end

class King < Cell
  def initialize(x, y, type, icon, color)
    super
  end
end

class Knight < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def can_move?(wanted_x, wanted_y)
    possible_moves = [[2, 1], [1, 2], [-2, 1], [-1, 2], [2, -1], [1, -2], [-2, -1], [-1, -2]]
    possible_moves.each do |move|
      if @x + move[0] == wanted_x && @y + move[1] == wanted_y
        return [@x + move[0], @y + move[1]]
      end
    end
    nil
  end

  def move(wanted_x, wanted_y)
    new_pos = can_move?(wanted_x, wanted_y)
    @x = new_pos[0]
    @y = new_pos[1]
  end
end

class Pawn < Cell
  def initialize(x, y, type, icon, color)
    super
  end

  def can_move?(wanted_x, wanted_y)
    board = Board.class_variable_get(:@@board)
    if board[wanted_x][wanted_y].type.nil?
      if @color == 'white'
        return @x + 1
      else
        return @x - 1
      end
    end
    nil
  end

  def move(wanted_x, wanted_y)
    @x = can_move?(wanted_x, wanted_y)
  end
end
