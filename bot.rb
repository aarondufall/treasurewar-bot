require 'SocketIO'

require_relative './util/world'
require_relative './util/known_world'

dev = "http://localhost:8000"
prod = "http://treasure-war:8000"
target = prod

@world = nil
@moved = false
def order(order, attrs, thinking = "")
  unless @moved
    emit(order, attrs)
    thinking = "Thinking #{thinking}" unless thinking == ""
    puts "ORDER: #{order}, #{attrs.inspect} #{thinking}"
    @moved = true
  end
end

client = SocketIO.connect(target) do
  after_start do
    emit("set name", `whoami`)
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

      if @world.you.carrying_treasure?
        # Move to stash
        if @world.you.position == @world.you.stash.to_point
          order("drop", {}, "Dropping at stash")
          known_world.reset_paths!
        else
          point = known_world.find_path_to_point(@world.you.stash.to_point)
          if point
            order("move", {
              dir: known_world.player.position.direction_from(point)
            }, "going home")
          end
        end
      else
        for item in @world.nearby_items
          if item.to_point == @world.you.position
            order("pick up", {})
            known_world.reset_paths!
          else
            point = known_world.find_path_to_point(item.to_point)
            order("move", {
              dir: known_world.player.position.direction_from(point)
            }, "acquiring tresure") if point
          end
        end
      end

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
        if free_space_point
          puts "TARGET POINT : #{free_space_point.inspect}"
          order("move", {
            dir: known_world.player.position.direction_from(free_space_point)
          }, "Exploring")
        end
      end

      unless @moved
        unseen_point = known_world.far_point(@world.you.stash.to_point)

        point = known_world.find_path_to_point(unseen_point)
        order("move", {
          dir: known_world.player.position.direction_from(point)
        }, "going to unseen point") if point
      end

      order("move", {
        dir: World::DIRECTIONS.sample
      }, "no fucking idea")

      # Valid commands:
      # emit("move", {dir: "n"})
      # emit("attack", {dir: "ne"})
      # emit("pick up", {dir: "ne"})
      # emit("throw", {dir: "ne"})
    end
  end
end
