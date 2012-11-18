require_relative "./point"

class Player
  attr_reader :health, :name, :carrying_treasure, :score, :position
  def initialize(hash)
    @health = hash["health"]
    @name   = hash["name"]
    @score  = hash["score"]
    @position = Point.new(hash["position"])
    @carrying_treasure = hash["carrying_treasure"]
  end

  def carrying_treasure?
    @carrying_treasure
  end
end
