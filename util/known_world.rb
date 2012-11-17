require_relative "./point"
require 'terminal-table'

class KnownWorld
  attr_reader :map, :known_walls, :player

  @@explored_area = []

  #Generate map from known wall points
  def initialize(known_walls = [], player)
    known_walls.reject!{|p| p.x.nil? || p.y.nil? }

    x_dimension = known_walls.map(&:x).sort.last
    y_dimension = known_walls.map(&:y).sort.last

    @map = []
    @explored_area = []

    @player = player

    @known_walls = known_walls.inject([]) do |result, element|
      result << [element.x, element.y]
    end

    create_map(x_dimension, y_dimension)
  end

  def print_map
    params = {
      :title => "Known World - Bitch!",
      :headings => (0...@map.first.size).to_a,
      :rows => @map
    }
    #STDOUT.puts("\e[H\e[2J")
    #puts Terminal::Table.new params
  end

  private

  def create_map(x, y)
    0.upto(y) do |y_point|
      #Row by row
      row = []
      0.upto(x) do |x_point|
        update_explored_area(x_point, y_point)
        row << case
          when wall_found_at?(x_point, y_point)
            'W'
          when player_found_at?(x_point, y_point)
            '@'
          else
            explored_area?(x_point, y_point) ? '.' : ' '
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

  def explored_area?(x_point, y_point)
   @@explored_area.include?([x_point, y_point])
  end

  def visible_to_player?(x_point, y_point)
    range = [-2, -1, 0, 1, 2]
    range.include?(x_point - @player.position.x) && range.include?(y_point - @player.position.y)
  end

  def update_explored_area(x_point, y_point)
    @@explored_area << [x_point, y_point] if visible_to_player?(x_point, y_point)
  end
end
