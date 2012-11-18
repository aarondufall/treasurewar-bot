class Treasure < Point
  def initialize(hash)
    super(hash)
  end

  def to_point
    Point.new(x: @x, y: @y)
  end
end
