# require 'debugger'
#
# class HangmanGame
#   attr_reader :hangman, :guesser
#   attr_accessor :guessed_letters, :word_state, :game_status, :bad_guesses
#
#   def initialize
#     puts "How many computer players?"
#     computer_players = gets.chomp.to_i
#     if computer_players == 1
#       puts "Who should be the hangman? computer or human?"
#       hangman = gets.chomp.downcase
#       if hangman == 'computer'
#         @hangman, @guesser = ComputerPlayer.new(self, true), HumanPlayer.new(self)
#       else
#         @hangman, @guesser = HumanPlayer.new(self, true), ComputerPlayer.new(self)
#       end
#     elsif computer_players == 2
#       @hangman, @guesser = ComputerPlayer.new(self, true), ComputerPlayer.new(self)
#     else
#       @hangman, @guesser = HumanPlayer.new(self, true), HumanPlayer.new(self)
#     end
#     @game_status = :playing
#     @guessed_letters = []
#     @bad_guesses = []
#   end
#
#   def start
#     set_game_up
#     play_game
#   end
#
#   def set_game_up
#     hangman.set_up
#   end
#
#   def play_game
#     until game_status != :playing
#       puts "Already guessed: #{guessed_letters}"
#       puts "======= Hangman: #{word_state} (#{word_state.length})"
#       guesser.guesser_turn
#       hangman.hangman_turn
#     end
#     puts self.game_status
#   end
#
#   def interpret(hangmans_verdict)
#     if hangmans_verdict.is_a? Array
#       # return array of indexes for matched chars
#       hangmans_verdict.each { |i| word_state[i] = guessed_letters.last.to_s }
#     elsif hangmans_verdict == 'no'
#       bad_guesses << guessed_letters.last
#     elsif hangmans_verdict == 'yes'
#       self.game_status = "GUESSER WINS"
#     end
#   end
# end
#
# class HumanPlayer
#   attr_reader :game
#
#   def initialize(game, hangman = false)
#     @game = game
#   end
#
#   def set_up
#     print "Enter the word length: "
#     game.word_state = '_' * gets.chomp.to_i
#   end
#
#   def hangman_turn
#     puts "================ Human hangman's turn ===================="
#     puts "Computer guesses: #{game.guessed_letters.last}"
#     puts "Please respond with 'yes' for a winning match,"
#     puts "'no' if the letter or word isn't a match,"
#     print "or the indexes of the matches with spaces, ex: 0 3 11: "
#     hangmans_verdict = gets.chomp
#     if hangmans_verdict[0].match(/\d/)
#       game.interpret(hangmans_verdict.split.map { |i| i.to_i })
#     else
#       game.interpret(hangmans_verdict)
#     end
#   end
#
#   def guesser_turn
#     guess = gets.chomp
#     if guess.length == 1 && game.guessed_letters.include?(guess)
#       puts "You already guessed that letter"
#       guess = guesser_turn
#     end
#
#     game.guessed_letters << guess
#   end
#
# end
#
# class ComputerPlayer
#   attr_reader :game
#   attr_accessor :word_state, :dictionary, :word
#
#   LETTERS = ("a".."z").to_a.collect { |letter| letter.to_sym }
#
#   def initialize(game, hangman = false)
#     @game = game
#     @dictionary = File.readlines("dictionary.txt").map {|line| line.strip.gsub(/[^a-z]/, '') }
#     @word = ''
#   end
#
#   def set_up
#     self.word = dictionary.sample
#     game.word_state = '_' * word.length
#   end
#
#   def hangman_turn
#     guess = game.guessed_letters.last
#     match_indexes = []
#     word.split(//).each_with_index { |x, i| match_indexes << i if x == guess}
#     if guess == word
#       hangmans_verdict = 'yes'
#     elsif !match_indexes.empty?
#       hangmans_verdict = match_indexes
#     else
#       hangmans_verdict = 'no'
#     end
#     game.interpret(hangmans_verdict)
#   end
#
#   def guesser_turn
#     update_dictionary
#     p dictionary
#     letters_to_use = LETTERS.select { |l| !game.guessed_letters.include?(l) }
#     indices_count = []
#     letters_to_use.count.times { indices_count << 0 }
#
#     dictionary.each do |word|
#       word.split(//).each do |letter|
#         indices_count[letters_to_use.index(letter.to_sym)] += 1 if letters_to_use.include?(letter.to_sym)
#       end
#     end
#
#
#     if dictionary.count == 1
#       game.guessed_letters << dictionary[0]
#     else
#       game.guessed_letters << letters_to_use[indices_count.index(indices_count.max)]
#     end
#   end
#
#   # def display_word_state
# #     puts "Secret word: #{word_state} (#{word_state.length} letters)"
# #   end
#
#   # def update_word_state(index_match_and_letter)
#   #   p "in update_word_state. guess = #{index_match_and_letter}"
#   #   if game_type == "human_guesser"
#   #     word_array = word.split(//)
#   #     if word.include?(index_match_and_letter)
#   #       indices = word_array.each_index.select { |i| word_array[i] == index_match_and_letter }
#   #       indices.each { |i| word_state[i] = index_match_and_letter }
#   #     end
#   #   else
#   #     if index_match_and_letter.is_a? Integer
#   #       word_state = "_" * index_match_and_letter
#   #     else
#   #       index_match_and_letter[0].each { |i| self.word_state[i] = index_match_and_letter[1].to_s }
#   #     end
#   #   end
#   #
#   #   word_state
#   # end
#
#   def update_dictionary
#     if game.guessed_letters.empty?
#       self.dictionary = dictionary.select { |w| w.length == game.word_state.length }
#     else
#       # remove words that don't have right letter at
#       # right index compared to game.word_state
#       self.dictionary = dictionary.select do |word|
#         add_word = true
#         word.split(//).each_with_index do |x, i|
#           game.word_state.split(//).each_with_index do |y, j|
#             add_word = false if (y != '_') && (x != y)
#           end
#         end
#         add_word
#       end
#
#       p "in update_dictionary. bad_guesses.last = #{game.bad_guesses.last}"
#       # remove words with bad_guesses.last from dictionary
#       self.dictionary = dictionary.select do |w|
#         !(w.split(//).include?(game.bad_guesses.last))
#       end
#
#     end
#   end
# end


class Hangman
  attr_reader :human_player, :computer_player
  attr_accessor :guessed_letters

  # gets game type, creates one human, one computer player, kicks off game_type
  #
  # to make it better: set how many computer (or human) players
  # create hangman player and guesser player (can be human or computer)
  # create each, start game
  #
  def initialize
    print "Enter type of game (computer_guesser or human_guesser): "
    game_type = gets.chomp

    @human_player = HumanPlayer.new(self)
    @computer_player = ComputerPlayer.new(game_type, self)
    @guessed_letters = []

    if game_type == "human_guesser"
      puts human_guesser
    else
      puts computer_guesser
    end
  end

  #starts game loop with human being guesser
  #
  #start game loop, no need for separate use cases
  # because each class (computer, human) should have same methods
  def human_guesser
    loop do
      print "Guessed letters: #{guessed_letters}\n"
      computer_player.display_word_state
      guess = human_player.guesser_turn
      if guess.length > 1
        if computer_player.check_for_win?(guess)
          return "YOU WIN"
        else
          puts "No, that's not it"
          guessed_letters << guess
        end
      else
        guessed_letters << guess
      end
      computer_player.update_word_state(guess)
      return "YOU WIN" if computer_player.check_for_win?
    end
  end

  def computer_guesser
    word_length = human_player.set_word_length
    computer_player.word_state = '_' * word_length
    computer_player.update_dictionary(word_length)
    computer_player.update_word_state(word_length)

    10.times do
      computer_player.guess
      hangmans_verdict = human_player.hangman_turn

      if hangmans_verdict.is_a? Array
        computer_player.update_word_state([hangmans_verdict, guessed_letters.last])
        computer_player.update_dictionary([hangmans_verdict, guessed_letters.last])
      elsif hangmans_verdict == 'yes'
        return 'COMPUTER WINS'
      else
        computer_player.update_dictionary(guessed_letters.last)
        puts 'No match, guess again.'
      end
    end
    puts "HANGMAN WINS"
  end

end

# needs:
#   as guesser:
#     guesser_turn
#       update_dictionary
# =>    guess based on that
#
#   as hangman:
# =>  hangman_turn
# =>    set_word_length
#
#
#
#
class ComputerPlayer
  LETTERS = ("a".."z").to_a.collect { |letter| letter.to_sym }

  attr_reader :word, :game, :game_type
  attr_accessor :word_state, :dictionary

  def initialize(game_type, game)
    @game = game
    @dictionary = File.readlines("dictionary.txt").map {|line| line.strip.gsub(/[^a-z]/, '') }
    p @dictionary
    @game_type = game_type

    if game_type == "human_guesser"
      # choose random word
      @word = dictionary.sample
      @word_state = "_" * @word.length
    else
      @word_state = ''
    end
  end

  # def guess
  #   if game.guessed_letters.empty?
  #     game.guessed_letters << first_guess
  #   else
  #
  #   end
  # end

  def guess
    p game.guessed_letters
    p dictionary

    letters_to_use = LETTERS.select { |l| !game.guessed_letters.include?(l) }
    p letters_to_use
    indices_count = []
    letters_to_use.count.times { indices_count << 0 }

    dictionary.each do |word|
      word.split(//).each do |letter|
        indices_count[letters_to_use.index(letter.to_sym)] += 1 if letters_to_use.include?(letter.to_sym)
      end
    end

    if dictionary.count == 1
      game.guessed_letters << dictionary[0]
    else
      game.guessed_letters << letters_to_use[indices_count.index(indices_count.max)]
    end
  end

  def display_word_state
    puts "Secret word: #{word_state} (#{word_state.length} letters)"
  end

  def update_word_state(index_match_and_letter)
    p "in update_word_state. guess = #{index_match_and_letter}"
    if game_type == "human_guesser"
      word_array = word.split(//)
      if word.include?(index_match_and_letter)
        indices = word_array.each_index.select { |i| word_array[i] == index_match_and_letter }
        indices.each { |i| word_state[i] = index_match_and_letter }
      end
    else
      if index_match_and_letter.is_a? Integer
        word_state = "_" * index_match_and_letter
      else
        index_match_and_letter[0].each { |i| self.word_state[i] = index_match_and_letter[1].to_s }
      end
    end

    word_state
  end

  def check_for_win?(guess = self.word_state)
    guess == word
  end

  def update_dictionary(var)
    if var.is_a? Array
      last_letter_and_index = var
      self.dictionary = dictionary.select do |word|
        add_word = true
        last_letter_and_index[0].each do |i|
          add_word = false if word[i] != last_letter_and_index[1].to_s
        end
        add_word
      end

    elsif var.is_a? Integer
      word_length = var
      self.dictionary = dictionary.select { |w| w.length == word_length }

    elsif var.is_a? Symbol
      letter_to_exclude = var.to_s
      self.dictionary = dictionary.select do |word|
        !word.split(//).include?(letter_to_exclude)
      end
    end
  end
end

class HumanPlayer
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def set_word_length
    print "Enter the word length: "
    gets.chomp.to_i
  end

  def hangman_turn
    puts "================ Hangman's turn ===================="
    puts "Computer guesses: #{game.guessed_letters.last}"
    puts "Please respond with 'yes' for a winning match,"
    puts "'no' if the letter or word isn't a match,"
    print "or the indexes of the matches with spaces, ex: 0 3 11: "
    hangmans_verdict = gets.chomp
    if hangmans_verdict[0].match(/\d/)
      # return array of indexes for matched chars
      hangmans_verdict.split.map { |index| index.to_i }
    else
      hangmans_verdict
    end
  end

  def guesser_turn
    begin
      guess = gets.chomp
      if guess.length == 1 && game.guessed_letters.include?(guess)
        raise RuntimeError.new("You already guessed that letter")
      end
    rescue RuntimeError => e
      puts "Please try again"
      retry
    end


    guess
  end

end