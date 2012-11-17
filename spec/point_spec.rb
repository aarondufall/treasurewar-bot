require_relative "../util/point"
require "rspec"


# Tick received [
#   {"messages"=>[],
#     "you"=>
#       {"name"=>"my bot name", "health"=>100, "score"=>nil, "carrying_treasure"=>false, "item_in_hand"=>nil,
#         "stash"=>{"x"=>26, "y"=>23, "treasures"=>[]},
#         "position"=>{"x"=>26, "y"=>23}},
#         "tiles"=>[
#           {"x"=>28, "y"=>21, "type"=>"wall"},
#           {"x"=>24, "y"=>22, "type"=>"wall"},
#           {"x"=>25, "y"=>22, "type"=>"wall"},
#           {"x"=>26, "y"=>22, "type"=>"wall"},
#           {"x"=>27, "y"=>22, "type"=>"wall"},
#           {"x"=>28, "y"=>22, "type"=>"wall"},
#           {"x"=>24, "y"=>24, "type"=>"wall"},
#           {"x"=>25, "y"=>24, "type"=>"wall"},
#           {"x"=>26, "y"=>24, "type"=>"wall"},
#           {"x"=>27, "y"=>24, "type"=>"wall"},
#           {"x"=>28, "y"=>24, "type"=>"wall"},
#           {"x"=>24, "y"=>25, "type"=>"wall"},
#           {"x"=>25, "y"=>25, "type"=>"wall"},
#           {"x"=>26, "y"=>25, "type"=>"wall"},
#           {"x"=>27, "y"=>25, "type"=>"wall"},
#           {"x"=>28, "y"=>25, "type"=>"wall"}
#         ], "nearby_players"=>[], "nearby_stashes"=>[], "nearby_treasure"=>[]}]

describe Point do
  let(:point) { Point.new(x: 5, y: 10)}

  describe "#direction_from" do
    it "should be n when point y <" do
      point.direction_from(Point.new(x: 5, y: 9)).should == :n
    end

    it "should be sw when point x < and point y >" do
      point.direction_from(Point.new(x: 4, y: 11)).should == :sw
    end
  end
end
