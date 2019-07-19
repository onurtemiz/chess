module InputValidation
  def is_ally?(wanted_x, wanted_y, player_color)
    @board[wanted_x][wanted_y].color == player_color
  end

  def valid_target?(player_color,input,target)
    target = get_converted_answer(target)
    if @board[input[0]][input[1]].type == 'king'
      return true if king_in_check_moves(@board[input[0]][input[1]]).include?([target[0], target[1]])
    elsif check?(player_color)
      return true if piece_in_check_moves(@board[input[0]][input[1]]).include?([target[0], target[1]])
    elsif @board[input[0]][input[1]].type == 'pawn' && (@board[input[0]][input[1]].can_passant_left || @board[input[0]][input[1]].can_passant_right)
      p 'can choose'
      if @board[input[0]][input[1]].color == 'black' && @board[target[0]-1][target[1]].type == 'pawn' && @board[target[0]-1][target[1]].can_killed
        return true
      elsif @board[input[0]][input[1]].color == 'white' && @board[target[0]+1][target[1]].type == 'pawn' && @board[target[0]+1][target[1]].can_killed
        return true
      end
    elsif @board[input[0]][input[1]].pos_moves.include?([target[0], target[1]]) && @board[target[0]][target[1]].type != 'king'
      return true
    end
    false
  end

  def get_target_piece(player_color,input)
    player_color == 'white' ? color = 'Beyaz' : color = 'Siyah'
    loop do
      puts "#{color} Lütfen #{@board[input[0]][input[1]].type.capitalize}'i Oynatmak İstediğiniz Yeri Seçin."
      target = get_user_input
      if valid_input?(target) && valid_target?(player_color,input,target)
        return get_converted_answer(target)
      end
    end
  end

  def valid_input?(input)
    numbers = ('1'..'8').to_a
    letters = ('a'..'h').to_a
    input.length == 2 && letters.include?(input[0]) && numbers.include?(input[1]) ? true : false
  end

  def pick_input?(input,player_color)
    valid_input?(input) && is_valid?(input,player_color) ? true : false
  end

  def is_valid?(input, player_color)
    input = get_converted_answer(input)
    if @board[input[0]][input[1]].color == player_color && @board[input[0]][input[1]].pos_moves.length.positive?
      if check?(player_color)
        if @board[input[0]][input[1]].type == 'king'
          return true unless king_in_check_moves(@board[input[0]][input[1]]).length.zero?
        elsif !(piece_in_check_moves(@board[input[0]][input[1]]).length.zero?)
          return true
        end
      else
        return true
      end
    end
    false
  end

  def decide_user_input(player_color)
    player_color == 'white' ? color = 'Beyaz' : color = 'Siyah'
    loop do
      puts "#{color} Lütfen Oynamak İstediğiniz Taşı Seçin (Örnek: a7) Ya Da Castling Yapın. (Örnek: castlıng a4 a7)"
      input = get_user_input
      if castling_input?(input)
        castling(input)
        break
      elsif pick_input?(input,player_color)
        normal_move(input,player_color)
        break
      end
    end
  end

  def get_user_input
    gets.chomp
  end

  def get_rook_king_by_input(input)
    king_location = get_converted_answer(input[9..10])
    king = @board[king_location[0]][king_location[1]]
    rook_location = get_converted_answer(input[12..13])
    rook = @board[rook_location[0]][rook_location[1]]
    return [rook,king]
  end

  def castling_input?(input)
    numbers = ('1'..'8').to_a
    letters = ('a'..'h').to_a
    if input.length == 14 && input[0..7] == 'castling' && letters.include?(input[9]) && letters.include?(input[12]) && numbers.include?(input[10]) && numbers.include?(input[13])
      rook,king = get_rook_king_by_input(input)
      if king.type == 'king' && rook.type == 'rook' && king.color == rook.color && castling?(rook,king)
        return true
      else
        return false
      end
    end
    false
  end

  def get_converted_answer(answer)
    letters = ('a'..'h').to_a
    y = letters.index(answer[0].downcase).to_s
    [answer[1].to_i - 1, y.to_i]
  end

end