# encoding: UTF-8
require 'debugger'
require 'colored'

class Game
  attr_accessor :board, :king_location_black, :king_location_white

  def initialize
    @board = []
    8.times do
      @board << ["_"] * 8
    end

    @player1 = HumanPlayer.new('white')
    @player2 = HumanPlayer.new('black')

    puts "Player 1 is blue"
    puts "Player 2 is red"

    place_pieces
    play_game
  end

  def display_board
    @board.each_with_index do |row, i|
      row.each_with_index do |char, j|
        if (i + j).even?
          if char.is_a? String
            print "   ".black_on_white
          elsif char.color == 'black'
            print " #{char.representation} ".red_on_white
          else
            print " #{char.representation} ".blue_on_white
          end
        elsif (i + j).odd?
          if char.is_a? String
            print "   ".white_on_black
          elsif char.color == 'black'
            print " #{char.representation} ".red_on_black
          else
            print " #{char.representation} ".blue_on_black
          end
        end
      end
      puts
    end
  end

  def place_pieces

    @board[1].each_with_index do |space, index|
      @board[1][index] = Pawn.new('black', [1,index])
    end

    @board[6].each_with_index do |space, index|
      @board[6][index] = Pawn.new('white', [6,index])
    end

    [0,7].each do |y|
      @board[0][y] = Rook.new('black', [0,y])
      @board[7][y] = Rook.new('white', [7,y])
    end

    [1,6].each do |y|
      @board[0][y] = Knight.new('black', [0,y])
      @board[7][y] = Knight.new('white', [7,y])
    end

    [2,5].each do |y|
      @board[0][y] = Bishop.new('black', [0,y])
      @board[7][y] = Bishop.new('white', [7,y])
    end

    @board[0][4] = King.new('black', [0,4])
    @king_location_black = [0,4]
    @board[0][3] = Queen.new('black', [0,3])

    @board[7][4] = King.new('white', [7,4])
    @king_location_white = [7,4]
    @board[7][3] = Queen.new('white', [7,3])
  end

  def find_pieces(color)
    pieces = []
    @board.each do |row|
      row.each do |char|
        if char.is_a? Piece
          pieces << char if char.color == color
        end
      end
    end
    pieces
  end

  def check?
    white_pieces = find_pieces('white')
    black_pieces = find_pieces('black')
    white_pieces.each do |piece|
      if piece.valid_move?(piece.location, @king_location_black, @board)
        return [true, 'black']
      end
    end
    black_pieces.each do |piece|
      if piece.valid_move?(piece.location, @king_location_white, @board)
        return [true, 'white']
      end
    end
    [false]
  end

  def check_mate?(color)

    pieces = find_pieces(color)

    pieces.each do |piece|
      original_location = piece.location
      possible_moves = possible_moves(piece)
      possible_moves.each do |possible| # possible = end_point
        # If move(possible) == true, check_mate stays true
        # Move on to next possible, same thing
        # Moves piece from original location to end_point (possible)
        end_point = test_move([original_location,possible])[0]
        original_king_location = test_move([original_location,possible])[1]
        unless check?[0]
          # test_move([possible,original_location])
          # Moves piece from end_point (possible) to original location
          undo_test_move([possible, original_location], end_point, original_king_location)
          return false
        end
        undo_test_move([possible, original_location], end_point, original_king_location)
      end
    end
    true
  end

  def possible_moves(piece)
    possibles = []
    8.times do |i|
      8.times do |j|
        possibles << [i,j] if piece.valid_move?(piece.location, [i,j], @board)
      end
    end
    possibles.delete_if {|x| x == piece.location}
    possibles
  end

  def test_move(move) #move : original, possible
    piece = @board[move[0][0]][move[0][1]] #original location
    end_point = @board[move[1][0]][move[1][1]] #possible location
    if piece.is_a? Piece
      if piece.valid_move?(move[0],move[1], @board)
        @board[move[0][0]][move[0][1]] = "_" #original = _
        @board[move[1][0]][move[1][1]] = piece #possible = piece

        piece.location = move[1]

        if piece.is_a? King
          if piece.color == 'black'
            original_king_location = @king_location_black
            @king_location_black = piece.location
          elsif piece.color == 'white'
            original_king_location = @king_location_white
            @king_location_white = piece.location
          end
        end
      end
    end
    [end_point, original_king_location] #possible location
  end

  def undo_test_move(move, end_point, original_king_location) #move: possible, original
    piece = @board[move[0][0]][move[0][1]] #possible location
    @board[move[1][0]][move[1][1]] = piece #original location
    @board[move[0][0]][move[0][1]] = end_point
    if piece.is_a? Piece
      piece.location = move[0]
    end
    if piece.is_a? King
      if piece.color == 'black'
        @king_location_black = original_king_location unless original_king_location.nil?
      elsif piece.color == 'white'
        @king_location_white = original_king_location unless original_king_location.nil?
      end
    end
  end

  def move(move)
    piece = @board[move[0][0]][move[0][1]]
    if piece.valid_move?(move[0],move[1], @board)
      @board[move[0][0]][move[0][1]] = "_"
      @board[move[1][0]][move[1][1]] = piece

      piece.location = move[1]
      # Change king location
      if piece.is_a? King
        @king_location_black = piece.location if piece.color == 'black'
        @king_location_white = piece.location if piece.color == 'white'
      end
    end
    if check?[0]
      if check_mate?(check?[1])
        puts "Checkmate! Game over."
        return true
      else
        player_color = check?[1] == 'black' ? 'red' : 'blue'
        puts "the #{player_color} king is in check"
      end
    end
    false
  end

  def color_match_piece?(move, player)
    piece = @board[move[0][0]][move[0][1]]
    piece.color == player.color
  end

  def checks_own_king?(move, player)
    checks = false
    end_point = test_move(move)[0]
    original_king_location = test_move(move)[1]
    if check?[1] == player.color
      checks = true
    end
    undo_test_move([move[1],move[0]], end_point, original_king_location)
    checks
  end

  def play_game
    whose_turn = 1
    while true
      while whose_turn == 1
        if take_turn(@player1)
          return false
        end
        whose_turn *= -1
      end
      while whose_turn == -1
        if take_turn(@player2)
          return false
        end
        whose_turn *= -1
      end
    end
  end

  def take_turn(player)
    display_board
    player_color = player.color == 'black' ? 'red' : 'blue'
    puts "#{player_color} player's turn"
    begin
      player_move = player.make_move
      piece = @board[player_move[0][0]][player_move[0][1]]

      unless piece.valid_move?(player_move[0], player_move[1], @board) && \
        color_match_piece?(player_move, player) && \
        !checks_own_king?(player_move, player)
        raise ArgumentError.new
      end
    rescue ArgumentError => e
      puts "Invalid move. Try again."
      retry
    end
    move(player_move)
  end
end


class Piece
  attr_accessor :color, :representation, :location

  def initialize(color, location)
    @color = color
    @location = location
  end

  def increment_to_end(start_point, end_point, increment, board)
    until start_point == end_point
      start_point = [start_point[0] + increment[0], start_point[1] + increment[1]]
      if board[start_point[0]][start_point[1]].is_a? Piece
        if board[start_point[0]][start_point[1]].color == self.color
          return false
        elsif board[start_point[0]][start_point[1]].color != self.color && start_point != end_point
          return false #there's a  piece blocking the path
        end
      end
    end
    true
  end
end

class Pawn < Piece

  def initialize(color, location)
    @representation = color == 'black' ? "♟" : "♙"
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)

    multiple = self.color == 'black' ? 1 : -1
    initial_row = multiple == 1 ? 1 : 6

    if board[initial_row].include?(self)
      [-1,1].each do |x|
        if board[start_point[0] + multiple][start_point[1] + x].is_a? Piece
          if board[start_point[0] + multiple][start_point[1] + x].color != self.color
            if [start_point[0] + multiple, start_point[1] + x] == end_point
              return true
            end
          end
        end
      end
      [(1 * multiple),(2 * multiple)].each do |y|
        unless board[start_point[0] + y][start_point[1]].is_a? Piece
          if [start_point[0] + y,start_point[1]] == end_point
            return true
          end
        end
      end

    else

      [-1,1].each do |x|
        if board[start_point[0] + multiple][start_point[1] + x].is_a? Piece
          if board[start_point[0] + multiple][start_point[1] + x].color != self.color
            if [start_point[0] + multiple,start_point[1] + x] == end_point
              return true
            end
          end

        end
      end

      unless board[start_point[0] + multiple][start_point[1]].is_a? Piece
        if [start_point[0] + multiple, start_point[1]] == end_point
          return true
        end
      end
    end
    false
  end

end

class Rook < Piece
  def initialize(color, location)
    @representation = color == 'black' ? "♜" : "♖"
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    if start_point[0] != end_point[0] && start_point[1] != end_point[1]
      return false
    end

    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    if delta_x > 0
      increment = [0, 1]
    elsif delta_x < 0
      increment = [0, -1]
    end
    if delta_y > 0
      increment = [1,0]
    elsif delta_y < 0
      increment = [-1,0]
    end

    increment_to_end(start_point, end_point, increment, board)
  end
end

class Knight < Piece
  KNIGHT_DELTAS = [[1,2], [2,1], [-1,-2], [-2,-1], [-1,2], [-2,1], [1,-2], [2, -1]]

  def initialize(color, location)
    @representation = color == 'black' ? "♞" : "♘"
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    possible_moves = []
    KNIGHT_DELTAS.each do |delta|
      possible_moves << [start_point[0] + delta[0], start_point[1] + delta[1]]
    end
    return false unless possible_moves.include?(end_point)

    if board[end_point[0]][end_point[1]].is_a? Piece
      if board[end_point[0]][end_point[1]].color == self.color
        return false
      end
    end
    true
  end

end

class Bishop < Piece

  def initialize(color, location)
    @representation =  color == 'black' ? "♝" : "♗"
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    if (start_point[0]-end_point[0]).abs != (start_point[1]-end_point[1]).abs
      return false
    end

    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    if delta_y.abs == delta_x.abs
      if (delta_y > 0 && delta_x > 0)
        increment = [1,1]
      elsif (delta_y > 0 && delta_x < 0)
        increment = [1,-1]
      elsif (delta_y < 0 && delta_x > 0)
        increment = [-1,1]
      elsif (delta_y < 0 && delta_x < 0)
        increment = [-1,-1]
      end
    end

    increment_to_end(start_point, end_point, increment, board)
  end

end

class Queen < Piece

  def initialize(color, location)
    if color == 'black'
      @representation = "♛"
    else
      @representation = "♕"
    end
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    # Diagonal moves
    if delta_y.abs == delta_x.abs
      if (delta_y > 0 && delta_x > 0)
        increment = [1,1]
      elsif (delta_y > 0 && delta_x < 0)
        increment = [1,-1]
      elsif (delta_y < 0 && delta_x > 0)
        increment = [-1,1]
      elsif (delta_y < 0 && delta_x < 0)
        increment = [-1,-1]
      end
    # Horizontal or vertical moves
    elsif delta_x > 0 && delta_y == 0
      increment = [0, 1]
    elsif delta_x < 0 && delta_y == 0
      increment = [0, -1]
    elsif delta_y > 0 && delta_x == 0
      increment = [1,0]
    elsif delta_y < 0 && delta_x == 0
      increment = [-1,0]
    else
      return false
    end

    increment_to_end(start_point, end_point, increment, board)
  end
end

class King < Piece
  KING_DELTAS = [[0,1], [1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1]]

  def initialize(color, location)
    @representation = color == 'black' ? "♚" : "♔"
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    possible_moves = []
    KING_DELTAS.each do |delta|
      possible_moves << [start_point[0] + delta[0], start_point[1] + delta[1]]
    end
    return false unless possible_moves.include?(end_point)

    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    increment = [delta_y, delta_x]

    increment_to_end(start_point, end_point, increment, board)
  end
end

class HumanPlayer
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def make_move
    coords = []

    ["from", "to"].each do |word|
      begin
        print "Enter coordinates you want to move #{word} (e.g. 0,0): "
        coord = gets.chomp.split(',').map{|x| x.to_i}
        coords << coord
        if coord.length != 2
          raise ArgumentError.new
        end
      rescue ArgumentError => e
        coords.pop
        puts "Invalid entry"
        retry
      end
    end

    coords
  end

end
