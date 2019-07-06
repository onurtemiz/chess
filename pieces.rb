# frozen_string_literal: true

class Cell
  attr_reader :icon
  def initialize(x, y, type = nil, icon = ' ',player =nil)
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
  def initialize(x, y, type, icon,player)
    super
  end
end

class Bishop < Cell
  def initialize(x, y, type, icon,player)
    super
  end
end

class Queen < Cell
  def initialize(x, y, type, icon,player)
    super
  end
end

class King < Cell
  def initialize(x,y,type,icon,player)
    super
  end
end

class Knight < Cell
  def initialize(x, y, type, icon,player)
    super
  end
end

class Pawn < Cell
  def initialize(x, y, type, icon,player)
    super
  end
end
