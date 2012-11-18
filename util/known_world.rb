require_relative "./point"
require_relative './pathfinder'
require 'terminal-table'



class KnownWorld
  attr_reader :map, :path_map, :pathfinder, :known_walls, :known_floors, :player

  @@explored_area = []

  @@destination = nil
  @@free_space_path = []
  @@point_navigate_path = []
  #Generate map from known wall points
  def initialize(tiles = [], player)
    tiles.reject!{|p| p.x.nil? || p.y.nil? }

    @map = []
    @explored_area = []

    @known_floors = {}
    @known_walls = {}
    @known_stashes = {}
    @player = player

    x_dimension = tiles.map(&:x).sort.last
    y_dimension = tiles.map(&:y).sort.last

    @@free_space_path.delete(@player.position)
    @@point_navigate_path.delete(@player.position)

    tiles.each do |tile_point|
      coord = [tile_point.x, tile_point.y]
      case tile_point.type
      when 'floor'
        @known_floors[coord] = tile_point
      when 'wall'
        @known_walls[coord] = tile_point
      when 'stash'
        @known_stashes[coord] = tile_point
      else
        raise "Unknown type : #{tile_point.type}" if tile_point.type
      end
    end

    @pathfinder = Pathfinder.new(x_dimension, y_dimension)
    update_path_blocks(@known_walls.keys)

    create_map(x_dimension, y_dimension)
  end

  def reset_paths!
    @@destination = nil
    @@free_space_path = []
    @@point_navigate_path = []
  end

  def print_map
    row_counter = 0
    rows = @map.inject([]) do |result, row|
        result << [row_counter] + row
        row_counter += 1
        result
      end

    params = {
      :title => "Known World - Bitch!",
      :headings => [" "] + (0...@map.first.size).to_a,
      :rows => rows
    }

    STDOUT.puts("\e[H\e[2J")
    puts Terminal::Table.new params
  end

  def died!
    @@free_space_path = []
  end

  def find_path_to_point(point)
    if @@point_navigate_path.size > 0 && point == @@destination
      return @@point_navigate_path.first
    else
      @@destination = point
      path = @pathfinder.find_shortest_path(@player.position, point)
      # path.each do |p|
      #   puts "INNER PATH : #{p.inspect}"
      # end
      # puts "---"
      @@point_navigate_path = path.map{|p| Point.new(x: p.location.x, y: p.location.y) }
      @@free_space_path = []
    end

    @@point_navigate_path.first
  end

  def find_free_space_target_point
    if @@free_space_path.size > 0
      #Already have a defined free space path
      #puts "RETURNING EXISTING TARGET : #{@@free_space_path}"
      #puts "RETURNING EXISTING TARGET POINT : #{@@free_space_path.first.inspect}"
      #exit
      return @@free_space_path.first
    else
      # Reset other path
      @@point = nil
      @@point_navigate_path = []
      #Calculate a new free space target point path
      @known_floors.inject(possible_points = []) do |result, (coord, point)|
        result << point if has_free_point?(point) && @player.position != point
        result
      end

      possible_points.sort! do |a,b|
        @pathfinder.map.distance(@player.position, a) <=> @pathfinder.map.distance(@player.position, b)
      end

      target_point = nil
      while possible_points.length > 0 && !target_point
        point = possible_points.shift

        # puts "HAS A FREE POINT MOTHERFUCKER : #{coord}"
        # puts "MY POINT : #{point.inspect}"
        # puts "PLAYER POINT : #{@player.position.inspect}"
        # puts "PATH : #{@pathfinder.find_shortest_path(@player.position, point).inspect}"

        if point && path = @pathfinder.find_shortest_path(@player.position, point)
          # path.each do |p|
          #   puts "INNER PATH : #{p.inspect}"
          # end
          # puts "---"
          @@free_space_path = path.map{|p| Point.new(x: p.location.x, y: p.location.y) }
          target_point = @@free_space_path.first
        end
      end

      target_point
    end



    # puts "Target : x: #{target_point.x}, y: #{target_point.y}"
    # puts "Start : x: #{@player.position.x}, y: #{@player.position.y}"
    # path.each do |p|
    #   puts "x: #{p.location.x}, y: #{p.location.y}"
    # end
    # puts pather.inspect
    puts "Target : #{target_point.inspect}"
    target_point
  end

  private

  def surrounding_coordinates_for_point(point)
    north     = [point.x, point.y - 1]
    northeast = [point.x + 1, point.y - 1]
    east      = [point.x + 1, point.y ]
    southeast = [point.x + 1, point.y + 1]
    south     = [point.x, point.y + 1]
    southwest = [point.x - 1, point.y + 1]
    west      = [point.x - 1, point.y]
    northwest = [point.x - 1, point.y - 1]

    [ north, northeast, east,
      southeast, south, southwest,
      west, northwest ]
  end

  def has_free_point?(point)
    #Find first cell, NOT present in @known_walls and @known_floors
    #That is also within bounds of board
    #Reject if not part of map (@map[y_coord][x_coord])
    surrounding_coordinates_for_point(point).any? do |surrounding_coord|
      @known_floors[surrounding_coord].nil? &&
      @known_walls[surrounding_coord].nil? &&
      @known_stashes[surrounding_coord].nil?
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
          update_path_blocks([x_point, y_point])
          'W'
        when floor_found_at?(x_point, y_point)
          @@free_space_path.include?(Point.new(:x => x_point, :y => y_point)) ? 'P' : '.'
        when stash_found_at?(x_point, y_point)
          '$'
        else
          update_path_blocks([x_point, y_point])
          @@free_space_path.include?(Point.new(:x => x_point, :y => y_point)) ? 'P' : ' '
          #' '
        end
      end
      @map << row
    end
    @map
  end

  def player_found_at?(x_point, y_point)
    @player.position.x == x_point && @player.position.y == y_point
  end

  def stash_found_at?(x_point, y_point)
    @known_stashes[[x_point, y_point]]
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
      @@explored_area << [x_point, y_point]
    end
  end

  def update_path_blocks(*coords)
    coords.each do |coord|
      @pathfinder.add_obstacle(coord)
    end
  end

  def reset_free_space_path
    @@free_space_path = []
  end

end
