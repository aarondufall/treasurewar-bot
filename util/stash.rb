require_relative "./point"

class Stash < Point
  attr_accessor :treasure
  def initialize(hash)
    @treasures = hash["treasures"]
    super(hash)
  end

  def to_point
    Point.new(x: @x, y: @y)
  end
end
