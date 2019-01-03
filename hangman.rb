require_relative "player"
require "csv"

class Game
  attr_accessor :player, :secret_word, :guessed_letters, :characters_left

  def initialize(players_name = "")
    @player = Player.new(players_name)
    @secret_word = ""
    @guessed_letters = []
    @characters_left = 0
  end

  def load_saved_game

     saved_games = CSV.open "saved_games.csv", headers: true, header_converters: :symbol
      puts "Here are all the saved games. To pick one, write the index when prompted to: "

      index = 0
      saved_games.each do |row|
        puts "index #{index.to_s}: #{row.to_s}"
        index += 1
      end

      print "Index of the saved game you want: "
      picked_game = STDIN.gets.to_i

      CSV.to_enum(:foreach, "saved_games.csv", headers: true, header_converters: :symbol).with_index(0) do |csv, rowno|
        next if rowno != picked_game

        @player.name = csv[:player_name]
        @player.score = csv[:score]
        @secret_word = csv[:secret_word]
        @guessed_letters = csv[:guessed_letters]
        @characters_left = csv[:characters_left]
      end

  end

  # pick a random word from the wordlist or load saved scenario
  def start
    puts "Do you want to open one of your saved games?[Y/n]"
    answer = STDIN.gets.downcase.chomp

    if answer == "y"
      play
    else
      File.foreach("wordlist.txt").each_with_index do |word, number|
        if word.length >= 5 && word.length <= 12
          @secret_word = word.downcase.chomp if rand < 1.0/(number+1)
        end
      end

      @characters_left = @secret_word.length

      play
    end
  end
  # display the found letters or
  def display_letters
    return nil if @secret_word.length == 0

    puts "Current player: #{@player.name} | score: #{@player.score} | lives left: #{@player.lives}"

    @secret_word.split("").each do |letter|
      if @guessed_letters.include? letter
        print letter.to_s
      else
        print "_"
      end
    end

    puts "\nThere are #{characters_left} characters characters"
  end

  def play
    
    while !lose? && !win?
      display_letters
      puts "Pick a letter or write 'save' to save your progress: "
      letter = STDIN.gets.chomp()

      if letter == "save"
        save
        return
      end

      occurances = @secret_word.count(letter)

      if occurances > 0
        @guessed_letters << letter
        @characters_left -= occurances
        @player.score += 10
      else
        @player.lives -= 1
      end
    end
  end

  def win?
    if @characters_left == 0
      @player.score += 50 + @player.lives * 10
      puts "Congratulations! You won!\nFinal score: #{@player.score}"
      return true
    end

    false
  end

  def lose?
    if @player.lives == 0
      puts "You lost. \nThe secret word was: #{@secret_word}\nFinal score: #{@player.score}"

      return true
    end

    false
  end

  def save
    CSV.open("saved_games.csv", "a+") do |csv|
      csv << [@player.name, @player.score, @secret_word, @guessed_letters, @characters_left]
    end
  end
end

if ARGV.length == 0
  game = Game.new("bagool")
  game.start
elsif ARGV.length == 1
  game = Game.new(ARGV[0])
  game.start
else
  puts "Wrong number of arguments. Expected 1 argument (the name of the player)"
end
