require 'SocketIO'

require_relative './util/world'
require_relative './util/known_world'

dev = "http://localhost:8000"
prod = "http://treasure-war:8000"
target = prod

@world = nil
client = SocketIO.connect(target) do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}

    # You have about 1 second between each tick
    on_event('tick') { |game_state|
      puts "Tick received #{game_state.inspect}"

      @world ||= World.new(game_state.first)

      game_state.each do |state|
        @world.update_from_state(state)
      end

      # while @world.tiles.size < 1 || @world.you.nil?
      #   puts "Waiting for fucking server..."
      #   sleep 1
      # end
      known_world = KnownWorld.new(@world.tiles, @world.you)
      known_world.print_map

      attackable_player = @world.nearby_players.first
      #.select{|p| p.x && p.y }.first
      if attackable_player
        puts "=="
        puts @world.nearby_players.inspect
        exit
      end
      if attackable_player && attackable_player.x && attackable_player.y && known_world.player.position
        # Random bot likes to fight!
        puts "FUCKING ATTACKING"

        dir = attackable_player.direction_from(
            known_world.player.position
          )
        puts "IN DIRECTION : #{dir}"

        emit("attack", {
          # dir: attackable_player.direction_from(
          #   known_world.player.position
          # )
          dir: dir
          #dir: known_world.player.position.direction_from(attackable_player)
        })
        exit
      else
        free_space_point = known_world.find_free_space_target_point
        puts "TARGET POINT : #{free_space_point.inspect}"
        dir = if free_space_point
                #free_space_point.direction_from(known_world.player.position)
                known_world.player.position.direction_from(free_space_point)
              else
                puts "No fucking idea"
                World::DIRECTIONS.sample
              end

        puts "Moving : #{dir}"
        emit("move", {
          dir: dir
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
    emit("set name", "Your mum2")
  end
end
