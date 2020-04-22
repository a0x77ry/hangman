#!/bin/env ruby

# frozen_string_literal: true

require_relative '../lib/game.rb'

DICT_PATH = 'dictionary.txt'
SAVE_PATH = 'save.dat'

def load_dictionary(file_path)
  s_word = File.readlines(file_path).map(&:chomp).select do |word|
    (5..12).include?(word.length) && !%w[save exit].include?(word)
  end
  s_word
end

def create_new_game
  word = load_dictionary(DICT_PATH).sample.downcase
  Game.new(word)
end

def ask_for_new_game
  res = yesorno { puts "\n\nDo you want to play another game? [y/n]" }
  res == 'y' ? create_new_game : exit
end

def yesorno
  response = ''
  until %w[y n].include?(response)
    yield
    response = gets.chomp.downcase
  end
  response
end

puts "Welcome to Hangman!\n\n"

load_game = yesorno { puts 'Do you want to load the previous game? [y/n]' }

case load_game
when 'y'
  if File.exist?(SAVE_PATH)
    puts "\nLoading game..."
    data = File.read(SAVE_PATH)
    game = Game.from_yaml(data)
  else
    puts "Error: Save file doesn't exist"
    game = create_new_game
  end
when 'n'
  game = create_new_game
end

loop do
  result = game.play_round
  case result
  when 'win'
    game = ask_for_new_game
  when 'save'
    puts "\nSaving game..."
    File.write(SAVE_PATH, game.to_yaml)
  when 'exit'
    exit
  end

  next unless game.guesses_left <= 0

  puts "\nYou lost"
  puts "The secret word was: #{game.secret_word}"
  game = ask_for_new_game
end
