# encoding: UTF-8
require 'debugger'

class Game
  attr_accessor :board, :king_location_black, :king_location_white

  def initialize
    @board = []
    8.times do
      @board << ["_"] * 8
    end

    player1 = HumanPlayer.new
    player2 = HumanPlayer.new

  end

  def display_board
    @board.each do |row|
      row.each do |char|
        unless char.is_a? String
          print "#{char.representation} "
        else
          print "#{char} "
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
          if char.color == color
            pieces << char
          end
        end
      end
    end
    pieces

  end

  def check?
    check = true
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
      possible_moves.each do |possible|
        # If move(possible) == true, check_mate stays true
        # Move on to next possible, same thing
        test_move([original_location,possible])
        unless check?
          return false
        end
        test_move([possible,original_location])
      end
    end


    true
      # get piece's possible moves
      # Move it to each of those possible moves, and check check?
      # Restore it to its original location
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

  def test_move(move)
    piece = @board[move[0][0]][move[0][1]]
    if piece.is_a? Piece
      if piece.valid_move?(move[0],move[1], @board)
        @board[move[0][0]][move[0][1]] = "_"
        @board[move[1][0]][move[1][1]] = piece

        piece.location = move[1]
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
        if piece.color == 'black'
          @king_location_black = piece.location
        elsif piece.color == 'white'
          @king_location_white = piece.location
        end
      end
    end
    if check?[0]

      if check_mate?(check?[1])
        puts "Checkmate"
      else
        puts "the #{check?[1]} king is in check"
      end
    end

  end

  # Piece is piece putting king in check
  # start_location is location of that piece
  # king_location is location of the king
  # Check if move from start to king is valid
  # def check?(piece, start_location, king_location)
#     unless piece.is_a? String
#       piece.valid_move?(start_location, king_location, @board)
#     else
#       false
#     end
#   end
end


class Piece
  attr_accessor :color, :representation, :location

  def initialize(color, location)
    @color = color
    @location = location
  end

  # Check if puts own king in check
  def puts_king_in_check?(move)
    # Put code here
  end
end

class Pawn < Piece

  def initialize(color, location)
    if color == 'black'
      @representation = "♟"
    else
      @representation = "♙"
    end
    super(color, location)
  end

  def initial_move
    # can be either 1 or 2 spaces forward
  end

  def subsequent_moves
    # can be 1 space forward or 1 space diagonally, if capturing another piece
  end

  def valid_move?(start_point, end_point, board)

    if board[1].include?(self) && self.color == 'black' #it's an initial move
      [-1,1].each do |x|
        if board[start_point[0] + 1][start_point[1] + x].is_a? Piece #there's a piece diagonal to it
          if board[start_point[0] + 1][start_point[1] + x].color != self.color #that piece is the opponent's piece
            if [start_point[0] + 1,start_point[1] + x] == end_point #the end point is one of the diagonals
              return true #you get the opponent's piece
            end
          end

        end
      end
      [1,2].each do |y|
        unless board[start_point[0] + y][start_point[1]].is_a? Piece #if you go down one spot or two spots they are empty
          if [start_point[0] + y,start_point[1]] == end_point #the end point is that spot
            return true #you can move your pawn
          end


        end
      end


    elsif board[6].include?(self) && self.color == 'white'
      [-1,1].each do |x|
        if board[start_point[0] - 1][start_point[1] + x].is_a? Piece #there's a piece diagonal to it
          if board[start_point[0] - 1][start_point[1] + x].color != self.color #that piece is the opponent's piece
            if [start_point[0] - 1,start_point[1] + x] == end_point #the end point is one of the diagonals
              return true #you get the opponent's piece
            end
          end

        end
      end
      [-1,-2].each do |y|
        unless board[start_point[0] + y][start_point[1]].is_a? Piece #if you go down one spot or two spots they are empty
          if [start_point[0] + y,start_point[1]] == end_point #the end point is that spot
            return true #you can move your pawn
          end


        end
      end
    elsif self.color == "white" #it's not an initial move

      [-1,1].each do |x|
        if board[start_point[0] - 1][start_point[1] + x].is_a? Piece #there's a piece diagonal to it
          if board[start_point[0] - 1][start_point[1] + x].color != self.color #that piece is the opponent's piece
            if [start_point[0] - 1,start_point[1] + x] == end_point #the end point is one of the diagonals
              return true #you get the opponent's piece
            end
          end

        end
      end

      unless board[start_point[0] - 1][start_point[1]].is_a? Piece #if you go up one spot it's empty
        if [start_point[0] - 1, start_point[1]] == end_point #the end point is that spot
          return true #you can move your pawn
        end

      end


    elsif self.color == "black"

      [-1,1].each do |x|
        if board[start_point[0] + 1][start_point[1] + x].is_a? Piece #there's a piece diagonal to it
          if board[start_point[0] + 1][start_point[1] + x].color != self.color #that piece is the opponent's piece
            if [start_point[0] + 1,start_point[1] + x] == end_point #the end point is one of the diagonals
              return true #you get the opponent's piece
            end
          end

        end
      end

      unless board[start_point[0] + 1][start_point[1]].is_a? Piece #if you go down one spot it's empty
        if [start_point[0] + 1, start_point[1]] == end_point #the end point is that spot
          return true #you can move your pawn
        end

      end
    end
    false
  end

  # Be aware of other pieces on board
end

class Rook < Piece
  def initialize(color, location)
    if color == 'black'
      @representation = "♜"
    else
      @representation = "♖"
    end
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    # if self.location


    if start_point[0] == end_point[0] || start_point[1] == end_point[1]
      true
      # p "it is a valid move"
    else
      # p "its not a valid move"
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

    current_point = start_point

    until current_point == end_point
      current_point = [current_point[0] + increment[0], current_point[1] + increment[1]]
      #check if there's a piece there
      if board[current_point[0]][current_point[1]].is_a? Piece
        if board[current_point[0]][current_point[1]].color == self.color
          return false
        end
      end

    end
    true

  end
end

class Knight < Piece
  KNIGHT_DELTAS = [[1,2], [2,1], [-1,-2], [-2,-1], [-1,2], [-2,1], [1,-2], [2, -1]]
  def initialize(color, location)
    if color == 'black'
      @representation = "♞"
    else
      @representation = "♘"
    end
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    possible_moves = []
    KNIGHT_DELTAS.each do |delta|
      possible_moves << [start_point[0]+delta[0],start_point[1] + delta[1]]
    end
    if possible_moves.include?(end_point)
      true
    else
      return false
    end

    current_point = start_point

    if board[end_point[0]][end_point[1]].is_a? Piece
      if board[current_point[0]][current_point[1]].color == self.color
        return false
      end
    end
    true
  end


end

class Bishop < Piece

  def initialize(color, location)
    if color == 'black'
      @representation = "♝"
    else
      @representation = "♗"
    end
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    if (start_point[0]-end_point[0]).abs == (start_point[1]-end_point[1]).abs
      true
    else
      return false
    end

    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    if (delta_y > 0 && delta_x > 0) && delta_y.abs == delta_x.abs
      increment = [1,1]
    elsif (delta_y > 0 && delta_x < 0) && delta_y.abs == delta_x.abs
      increment = [1,-1]
    elsif (delta_y < 0 && delta_x > 0) && delta_y.abs == delta_x.abs
      increment = [-1,1]
    elsif (delta_y < 0 && delta_x < 0) && delta_y.abs == delta_x.abs
      increment = [-1,-1]
    end

    current_point = start_point

    until current_point == end_point
      current_point = [current_point[0] + increment[0], current_point[1] + increment[1]]
      #check if there's a piece there
      if board[current_point[0]][current_point[1]].is_a? Piece
        if board[current_point[0]][current_point[1]].color == self.color
          return false
        end
      end
    end
    true
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
    if (delta_y > 0 && delta_x > 0) && delta_y.abs == delta_x.abs
      increment = [1,1]
    elsif (delta_y > 0 && delta_x < 0) && delta_y.abs == delta_x.abs
      increment = [1,-1]
    elsif (delta_y < 0 && delta_x > 0) && delta_y.abs == delta_x.abs
      increment = [-1,1]
    elsif (delta_y < 0 && delta_x < 0) && delta_y.abs == delta_x.abs
      increment = [-1,-1]
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

    current_point = start_point

    until current_point == end_point
      current_point = [current_point[0] + increment[0], current_point[1] + increment[1]]
      #check if there's a piece there
      if board[current_point[0]][current_point[1]].is_a? Piece
        if board[current_point[0]][current_point[1]].color == self.color
          return false
        end
      end
    end
    true
  end
end

class King < Piece
  KING_DELTAS = [[0,1], [1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1]]

  def initialize(color, location)
    if color == 'black'
      @representation = "♚"
    else
      @representation = "♔"
    end
    super(color, location)
  end

  def valid_move?(start_point, end_point, board)
    possible_moves = []
    KING_DELTAS.each do |delta|
      possible_moves << [start_point[0]+delta[0],start_point[1] + delta[1]]
    end
    if possible_moves.include?(end_point)
      true
    else
      return false
    end

    delta_y =  end_point[0] - start_point[0]
    delta_x =  end_point[1] - start_point[1]

    # Diagonal moves
    if delta_y > 0 && delta_x > 0
        increment = [1,1]
    elsif delta_y > 0 && delta_x < 0
        increment = [1,-1]
    elsif delta_y < 0 && delta_x > 0
        increment = [-1,1]
    elsif delta_y < 0 && delta_x < 0
        increment = [-1,-1]
    # Horizontal or vertical moves
    elsif delta_x > 0 && delta_y == 0
      increment = [0, 1]
    elsif delta_x < 0 && delta_y == 0
      increment = [0, -1]
    elsif delta_y > 0 && delta_x == 0
      increment = [1,0]
    elsif delta_y < 0 && delta_x == 0
      increment = [-1,0]
    end

    current_point = start_point

    until current_point == end_point
      current_point = [current_point[0] + increment[0], current_point[1] + increment[1]]
      #check if there's a piece there
      if board[current_point[0]][current_point[1]].is_a? Piece
        if board[current_point[0]][current_point[1]].color == self.color
          return false
        end
      end
    end
    true
  end
end

class HumanPlayer

  def make_move
    print "Enter coordinates you want to move from and to (e.g. 0,0 1,1): "
    start_coord = gets.chomp.split(',')
    end_coord = gets.chomp.split(',')
    [start_coord, end_coord]
  end

end
