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

    @known_floors = {}
    @known_walls = {}
    @unknown_tiles = {}

    @player = player
    puts "PLAYER POSITION : #{@player.position.inspect}"

    #TODO : Don't fuck around with unknown tiles. I think we don't actually give a flying fuck.
    tiles.each do |tile_point|
      coord = [tile_point.x, tile_point.y]
      case tile_point.type
      when 'floor'
        @known_floors.update(coord => tile_point)
      when 'wall'
        @known_walls.update(coord => tile_point)
      else
        @unknown_tiles.update(coord => tile_point)
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
    puts @unknown_tiles.size.inspect
  end

  def explore_new_point
    #Find closest floor tile with no wall around it
    # target_coord, target_point = @known_floors.detect do |coord, point|
    #   #Has an adjacent tile with no wall || floor tile
    #   explore_nearby?(point)
    # end

    points = @known_floors.select do |coord, point|
      #explore_nearby?(point)
      [point.x, point.y] != [@player.position.x, @player.position.y] && has_free_point?(point)
    end

    puts points.inspect

    puts "TARGETS : #{points.size}"



    #TODO : Loop through the fucking target points and find one that is accessible via a floor space
    target_point = points.first[1].inspect
    puts "Targetting : #{target_point.inspect}"
    target_point
  end

  private

  # def explore_nearby?(point)
  #   return true unless \
  #     point.x, point.y == @player.position ||
  #     has_free_point?(point)
  #   false
  # end

  def has_free_point?(point)
    north     = [point.x, point.y - 1]
    northeast = [point.x + 1, point.y - 1]
    east      = [point.x + 1, point.y ]
    southeast = [point.x + 1, point.y + 1]
    south     = [point.x, point.y + 1]
    southwest = [point.x - 1, point.y + 1]
    west      = [point.x - 1, point.y]
    northwest = [point.x - 1, point.y - 1]

    #Find first cell, NOT present in @known_walls and @known_floors
    #That is also within bounds of board
    [ north, northeast, east,
      southeast, south, southwest,
    west, northwest ].any? do |surrounding_coord|
      @known_walls[surrounding_coord].nil? && @known_floors[surrounding_coord].nil?
    end
  end

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
          '.'
        when unknown_tile_at?(x_point, y_point)
          '?'
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

  def unknown_tile_at?(x_point, y_point)
    @unknown_tiles[[x_point, y_point]]
  end

  def wall_found_at?(x_point, y_point)
    @known_walls[[x_point, y_point]]
  end

  def floor_found_at?(x_point, y_point)
    @known_floors[[x_point, y_point]]
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
