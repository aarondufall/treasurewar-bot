require "ir_b"
class Point
  attr_accessor :x, :y, :type

  include Comparable

  def initialize(hash)
    @x    = hash["x"] || hash[:x]
    @y    = hash["y"] || hash[:y]
    @type = hash["type"] || hash[:type]
  end

  def direction_from(point)
    return nil unless @x && @y && point && point.x && point.y
    dx = point.x - @x
    dy = point.y - @y
    case [dx <=> 0, dy <=> 0]
    when [0, -1] then :n
    when [1, -1] then :ne
    when [1, 0] then :e
    when [1, 1] then :se
    when [0, 1] then :s
    when [-1, 1] then :sw
    when [-1, 0] then :w
    when [-1, -1] then :nw
    when [0, 0] then raise("The point at the same position")
    end
  end

  def adjacent?(point)
    (point.x - @x).abs <= 1 && (point.y - @y).abs <= 1
  end

  def position_after(direction)
    case direction
    when :n  then Point.new(x: @x    , y: @y - 1)
    when :ne then Point.new(x: @x + 1, y: @y - 1)
    when :e  then Point.new(x: @x + 1, y: @y)
    when :se then Point.new(x: @x + 1, y: @y + 1)
    when :s  then Point.new(x: @x    , y: @y + 1)
    when :sw then Point.new(x: @x - 1, y: @y + 1)
    when :w  then Point.new(x: @x - 1, y: @y)
    when :nw then Point.new(x: @x - 1, y: @y - 1)
    else raise("Invalid direction #{direction.to_s}")
    end
  end

  def <=> (point)
    if @x == point.x && @y == point
      0
    elsif @x < point.x || @y < point
      -1
    else
      1
    end
  end

  def magnitude(point)
    (@x - point.x).abs + (@y - point.y).abs
  end

  def == (point)
    @x == point.x && @y == point.y
  end
end
