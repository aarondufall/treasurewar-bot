require 'SocketIO'

require_relative './util/world'
require_relative './util/known_world'

dev = "http://localhost:8000"
prod = "http://treasure-war:8000"
target = prod

@world = nil
@moved = false
def order(order, attrs)
  unless @moved
    emit(order, attrs)
    puts "ORDER: #{order}, #{attrs.inspect}"
    @moved = true
  end
end

client = SocketIO.connect(target) do
  after_start do
    emit("set name", "mtcmorris")
  end
  before_start do
    on_message {|message| puts "incoming message: #{message}"}

    # You have about 1 second between each tick

    on_event('tick') do |game_state|
      puts "Tick received #{game_state.inspect}"

      @moved = false

      @world ||= World.new(game_state.first)

      game_state.each do |state|
        @world.update_from_state(state)
      end

      # while @world.tiles.size < 1 || @world.you.nil?
      #   puts "Waiting for fucking server..."
      #   sleep 1
      # end
      known_world = KnownWorld.new(@world.tiles, @world.you)
      known_world.died! if game_state.first["messages"].include?({"notice" => "You died :("})

      known_world.print_map

      for attackable_player in @world.nearby_players
        if attackable_player.position.adjacent? @world.you.position
          dir = @world.you.position.direction_from(
              attackable_player.position
            )

          order("attack", { dir: dir })
        end
      end

      unless @moved
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
        order("move", {
          dir: dir
        })
      end

      # Valid commands:
      # emit("move", {dir: "n"})
      # emit("attack", {dir: "ne"})
      # emit("pick up", {dir: "ne"})
      # emit("throw", {dir: "ne"})
    end
  end
end
