class MasterMind
  def initialize
    @computer_choice == computer_select
  end

  def play_game
    computer_choice = computer_select
    puts computer_choice
    num_guesses = 0
    while num_guesses < 10
      new_guess = user_guess
      if winning_guess?(new_guess, computer_choice)
        puts "You guessed correctly!"
        break
      else
        puts evaluate(new_guess, computer_choice)
      end
      num_guesses += 1
    end
  end

  def computer_select
    colors = ["R", "G", "B", "Y", "O", "P"]
    choice = colors.sample(4)
    choice
  end

  def user_guess
    print "Enter a guess (format \"A B C D\"): "
    begin
      guess = gets.chomp
      if guess.length != 7
        raise ArgumentError.new
      end
    rescue ArgumentError => e
      puts "Try again"
      retry
    end

    guess_arr = guess.split(" ")
    guess_arr
  end

  def winning_guess?(guess, computer_choice)
    guess.length.times do |i|
      return false if guess[i] != computer_choice[i]
    end
    true
  end

  def evaluate(guess, computer_choice)
    message = ""
    guess.each_with_index do |spot, index|
      if computer_choice.include?(spot)
        if spot == computer_choice[index]
          message += "Letter #{index + 1} is in the correct spot.\n"
        else
          message += "Letter #{index + 1} is not in the correct spot.\n"
        end
      else
        message += "That letter is not included.\n"
      end
    end
    message
  end
end

game = MasterMind.new
game.play_game