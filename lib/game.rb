# frozen_string_literal: true

require 'yaml'

# A game class for Hangman
class Game
  def self.from_yaml(str)
    data = YAML.load(str)
    new(
      data[:secret_word],
      data[:found_letters],
      data[:missed_letters],
      data[:guesses_left]
    )
  end

  attr_accessor :guesses_left
  attr_reader :secret_word

  def initialize(
    secret_word,
    found_letters = [],
    missed_letters = [],
    guesses_left = 6
  )
    @secret_word = secret_word
    @found_letters = found_letters
    @missed_letters = missed_letters
    self.guesses_left = guesses_left
  end

  def to_yaml
    YAML.dump(
      { secret_word: secret_word,
        found_letters: @found_letters,
        missed_letters: @missed_letters,
        guesses_left: guesses_left }
    )
  end

  def play_round
    show_message
    puts "\nEnter 'save' to save the game or 'exit' to exit"
    puts 'Guess a letter or the whole word: '
    guess = gets.chomp
    if guess.length > 1
      return guess if %w[save exit].include?(guess)

      guess == secret_word ? corrent_word : wrong_word
    else
      secret_word.split('').include?(guess) ? correct_letter(guess) : wrong_letter(guess)
    end
  end

  private

  def show_message
    displayed_word = hide_secret_letters(secret_word, @found_letters)
    puts "\n#{'Word'.ljust(15)} : #{displayed_word.join.center(20)}\n"\
         "#{'Missed letters'.ljust(15)} : #{@missed_letters.join(',')
                                           .center(20)}\n"\
         "#{'Guesses left'.ljust(15)} : #{guesses_left.to_s.center(20)}\n"
  end

  def hide_secret_letters(word, known_letters)
    word.split('').map do |letter|
      known_letters.include?(letter) ? letter : '_'
    end
  end

  def corrent_word
    puts 'You win!'
    'win'
  end

  def wrong_word
    puts 'Wrong guess.'
    self.guesses_left -= 1
    'missed'
  end

  def correct_letter(guess)
    if @found_letters.include?(guess)
      puts "You've already tried this letter."
    else
      puts 'Your guess is correct'
      @found_letters << guess
      correct_word unless hide_secret_letters(secret_word, @found_letters)
                          .include?('_')
    end
  end

  def wrong_letter(guess)
    if @missed_letters.include?(guess)
      puts "You've already tried this letter."
    else
      puts 'You missed.'
      @missed_letters << guess
      self.guesses_left -= 1
    end
  end
end
