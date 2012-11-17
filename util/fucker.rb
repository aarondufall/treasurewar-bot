require_relative "./player"

class Fucker < Player
  attr_reader :name, :item_in_hand, :stash, :treasures

#       {"name"=>"my bot name", "health"=>100, "score"=>nil, "carrying_treasure"=>false, "item_in_hand"=>nil,
#         "stash"=>{"x"=>26, "y"=>23, "treasures"=>[]},
  def initialize(hash)
    @name = hash['name']
    @item_in_hand = hash['item_in_hand']
    @stash = Point.new(hash['stash'])
    @treasures = hash['treasures']

    super(hash)
  end

  def carrying_treasure?
    @carrying_treasure
  end
end


#Anything not in the array
# Construct view area
# Fill in all
