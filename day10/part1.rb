#!/usr/bin/env ruby

class SpaceObject
  ASTEROID = "#"

  def asteroid?
    @type == ASTEROID
  end

  attr_reader :x
  attr_reader :y
  attr_reader :type
  attr_accessor :visibility_map
  def initialize(x, y, type)
    @x = x
    @y = y
    @type = type
    @visibility_map = {}
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def visible_objects
    @visibility_map.values.uniq.size
  end
end

input = File.read(ARGV[0]).split("\n").map { |r| r.split("") }
asteroids = []
input.each_with_index do |r, r_idx|
  r.each_with_index do |o, o_idx|
    so = SpaceObject.new(o_idx, r_idx, o)
    asteroids << so if so.asteroid?
  end
end


asteroids.each do |base|
  asteroids.each do |obj|
    next if obj == base

    delta_x = base.x - obj.x
    delta_y = base.y - obj.y

    if delta_x == 0
      angle = (obj.y > base.y ? "down" : "up")
    elsif delta_y == 0
      angle = (obj.x > base.x ? "right" : "left")
    else
      prefix = case
      when obj.y < base.y && obj.x > base.x then "ne-"
      when obj.y > base.y && obj.x > base.x then "se-"
      when obj.y < base.y && obj.x < base.x then "nw-"
      when obj.y > base.y && obj.x < base.x then "sw-"
      end
      angle = delta_y.to_f / delta_x.to_f
    end
    base.visibility_map[ [obj.x, obj.y] ] = "#{prefix}#{angle}"
  end
end

best = asteroids.max_by(&:visible_objects)
puts "[#{best.x}, #{best.y}]"
puts best.visible_objects
