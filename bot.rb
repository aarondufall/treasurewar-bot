require 'SocketIO'

require_relative './util/world'
require_relative './util/known_world'

@world = nil
client = SocketIO.connect("http://localhost:8000") do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}

    # You have about 1 second between each tick
    on_event('tick') { |game_state|
      #puts "Tick received #{game_state.inspect}"

      @world ||= World.new(game_state.first)

      game_state.each do |state|
        @world.update_from_state(state)
      end


      #puts @world.tiles.inspect
      puts "=" * 100

      while @world.tiles.size < 1 || @world.you.nil?
        puts "Waiting for fucking server..."
        sleep 1
      end
      known_world = KnownWorld.new(@world.tiles, @world.you)

      known_world.print_map
      #Build known screen map
      # => Get largest X
      # => Get largest Y
      # => Create square (anything in tiles is a wall)

      # Bot logic goes here...
      if @world.nearby_players.any?
        # Random bot likes to fight!
        emit("attack", {
          dir: @world.nearby_players.first.direction_from(
            @world.position
          )
        })
      else
        puts @world.valid_move_directions.inspect * 500
        # Random bot moves randomly!
        emit("move", {
          dir: @world.valid_move_directions.sample
        })
      end

      # Valid commands:
      # emit("move", {dir: "n"})
      # emit("attack", {dir: "ne"})
      # emit("pick up", {dir: "ne"})
      # emit("throw", {dir: "ne"})
    }
  end

  after_start do
    emit("set name", "my bot name")
  end
end
