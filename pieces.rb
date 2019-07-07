# frozen_string_literal: true

class Cell
  attr_reader :icon
  def initialize(x, y, type = nil, icon = ' ', player = nil)
    @x = x
    @y = y
    @type = type
    @icon = icon
    @player = player
  end

  def to_s
    @icon
  end
end

class Rook < Cell
  def initialize(x, y, type, icon, player)
    super
  end
end

class Bishop < Cell
  def initialize(x, y, type, icon, player)
    super
  end
end

class Queen < Cell
  def initialize(x, y, type, icon, player)
    super
  end
end

class King < Cell
  def initialize(x, y, type, icon, player)
    super
  end
end

class Knight < Cell
  attr_reader :x,:y
  def initialize(x, y, type, icon, player)
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
  def initialize(x, y, type, icon, player)
    super
  end
end
