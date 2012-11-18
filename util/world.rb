require_relative "./point"
require_relative "./stash"
require_relative "./you"
require_relative "./player"
require "ir_b"

class World
  attr_accessor :nearby_players, :nearby_stashes, :nearby_treasure
  attr_accessor :you
  attr_accessor :tiles

  DIRECTIONS = [:n, :nw, :ne, :e, :se, :s, :sw, :w]

  def initialize(state)
    @tiles = []

    update_from_state(state)
  end

  def update_from_state(state)
    @you = You.new(state["you"])

    update_world_tiles(state)
    update_nearby_players(state)
  end

  def update_world_tiles(state)
    for tile in state["tiles"]
      point = Point.new(tile)
      @tiles.push point unless @tiles.include?(point)
    end
  end

  def update_nearby_players(state)
    @nearby_players = []

    for player in state["nearby_players"]
      puts "FUCK YOUR MUM"
      puts player.inspect
      @nearby_players.push Player.new(player)
    end
  end

  def valid_move_directions
    DIRECTIONS.reject{|dir|
      @tiles.include? you.position.position_after(dir)
    }
  end
end
