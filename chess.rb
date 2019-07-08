require './pieces'
require './board'


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
    p [new_x,new_y]
    @board[new_x][new_y] = @board[x][y]
    @board[x][y] = Cell.new(x, y)
    display
  end

  def is_ally?(wanted_x, wanted_y, player_color)
    return true if @board[wanted_x][wanted_y].color == player_color

    false
  end

  def is_valid?(x,y,player_color)
    @board[x.to_i][y.to_i].color == player_color ? true : false
  end

  def play_piece(x,y,player_color)
    target = get_user_answer(player_color,'Hareket Ettirmek İstediğiniz Yer İçin')
    p target
    move_piece(x,y,target[0],target[1])
  end

  def get_converted_answer(answer)
    letters = ('a'..'h').to_a
    y = letters.index(answer[0].downcase).to_s
    [answer[1].to_i-1,y.to_i]
  end

  def show_possible_moves(x,y)
    p @board[x][y].pos_moves
  end

  def play_a_piece(player_color)
    answer = get_user_answer(player_color,'pick','Oynayacağınız Taşı Seçmek İçin')
    show_possible_moves(answer[0],answer[1])
    play_piece(answer[0],answer[1],player_color)
  end

  def get_user_answer(player_color,option='play',for_what)
    numbers = (0..7).to_a
    loop do
      location=''
      puts "#{player_color.capitalize} Lütfen #{for_what} Koordinat Girin. Örnek: a8"
      location = get_converted_answer(gets.chomp.downcase)
      p location
      if location.length == 2 && numbers.include?(location[0].to_i) && numbers.include?(location[1].to_i)
        if option == 'pick'
          if is_valid?(location[0],location[1],player_color)
            return location
          else
            next
          end
        else
          return location
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