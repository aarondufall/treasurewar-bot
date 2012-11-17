require_relative "./point"
require 'terminal-table'

class KnownWorld
  attr_reader :map, :known_walls, :known_floors, :player, :unknown_tiles

  @@explored_area = []

  #Generate map from known wall points
  def initialize(tiles = [], player)
    tiles.reject!{|p| p.x.nil? || p.y.nil? }

    x_dimension = tiles.map(&:x).sort.last
    y_dimension = tiles.map(&:y).sort.last

    @map = []
    @explored_area = []
    @known_floors = []
    @known_walls = []
    @unknown_tiles = []

    @player = player

    tiles.each do |tile_point|
      case tile_point.type
        when 'floor'
          @known_floors << [tile_point.x, tile_point.y]
        when 'wall'
          @known_walls << [tile_point.x, tile_point.y]
        else
          @unknown_tiles << [tile_point.x, tile_point.y]
      end
    end

    create_map(x_dimension, y_dimension)
  end

  def print_map
    params = {
      :title => "Known World - Bitch!",
      :headings => (0...@map.first.size).to_a,
      :rows => @map
    }
    STDOUT.puts("\e[H\e[2J")
    puts Terminal::Table.new params
    puts @unknown_tiles.uniq.size.inspect
  end

  def explore_target_point
    #Find closest unknown tile to target

  end

  private

  def create_map(x, y)
    0.upto(y) do |y_point|
      #Row by row
      row = []
      0.upto(x) do |x_point|
        update_explored_area(x_point, y_point)
        row << case
          when player_found_at?(x_point, y_point)
            '@'
          when wall_found_at?(x_point, y_point)
            'W'
          when floor_found_at?(x_point, y_point)
            explored_area?(x_point, y_point) ? '.' : '?'
          else
            ' '
          end
      end
      @map << row
    end
    @map
  end

  def player_found_at?(x_point, y_point)
    @player.position.x == x_point && @player.position.y == y_point
  end

  def wall_found_at?(x_point, y_point)
    @known_walls.include?([x_point, y_point])
  end

  def floor_found_at?(x_point, y_point)
    @known_floors.include?([x_point, y_point])
  end

  def explored_area?(x_point, y_point)
   @@explored_area.include?([x_point, y_point])
  end

  def visible_to_player?(x_point, y_point)
    range = [-3, -2, -1, 0, 1, 2, 3]
    range.include?(x_point - @player.position.x) && range.include?(y_point - @player.position.y)
  end

  def update_explored_area(x_point, y_point)
    if visible_to_player?(x_point, y_point)
      @unknown_tiles.delete([x_point, y_point])
      @@explored_area << [x_point, y_point]
    end
  end
end
