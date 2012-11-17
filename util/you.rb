class You
  attr_reader :health, :name, :carrying_treasure, :score, :position, :stash


#{"name"=>"my bot name", "health"=>100, "score"=>nil, "carrying_treasure"=>false, "item_in_hand"=>nil,
# "stash"=>{"x"=>26, "y"=>23, "treasures"=>[]},


  def initialize(hash)
    @health = hash["health"]
    @name   = hash["name"]
    @score  = hash["score"]
    @carrying_treasure = hash["carrying_treasure"]
    @position = Point.new(hash["position"])
    @stash = Stash.new(hash["stash"])
  end
end
