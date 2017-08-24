class Player
  attr_accessor :name, :score, :lives

  def initialize(name = "")
    @name = name
    @score = 0
    @lives = 5
  end
end
