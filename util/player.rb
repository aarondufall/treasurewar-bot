require_relative "./point"

class Player < Point
  attr_reader :health, :name, :carrying_treasure, :score
  def initialize(hash)
    @health = hash["health"]
    @name   = hash["name"]
    @score  = hash["score"]
    @carrying_treasure = hash["carrying_treasure"]

    super(hash)
  end

  def carrying_treasure?
    @carrying_treasure
  end
end
