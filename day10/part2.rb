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
      if obj.y < base.y
        angle = "up"
      else
        angle = "down"
      end
    elsif delta_y == 0
      if obj.x < base.x
        angle = "left"
      else
        angle = "right"
      end
    else
      angle = (delta_y.to_f/ delta_x.to_f).abs
    end

    quadrant = case
    when delta_y == 0 && angle == "left" ||
         obj.y < base.y && obj.x < base.x

      :nw
    when delta_x == 0 && angle == "up" ||
         obj.y < base.y && obj.x > base.x

      :ne
    when delta_y == 0 && angle == "right" ||
         obj.y > base.y && obj.x > base.x

      :se
    when delta_x == 0 && angle == "down" ||
         obj.y > base.y && obj.x < base.x

      :sw
    end

    base.visibility_map[ [obj.x, obj.y] ] = {
      quadrant: quadrant,
      angle:    angle,
    }
  end
end

best = asteroids.max_by(&:visible_objects)
puts "chose location: [#{best.x}, #{best.y}] " +
     "(#{best.visible_objects} seen)"

quad_asteroids = [
  { quadrant: :ne, asteroids: {} },
  { quadrant: :se, asteroids: {} },
  { quadrant: :sw, asteroids: {} },
  { quadrant: :nw, asteroids: {} },
]

quad_asteroids.each do |quad|
  quad[:asteroids] = best.visibility_map.inject({}) do |a, o|
    if o[1][:quadrant] == quad[:quadrant]
      a[o[1][:angle]] ||= []
      a[o[1][:angle]] << o
    end

    a
  end

  quad[:asteroids].keys.each do |a|
    quad[:asteroids][a] = quad[:asteroids][a].sort do |a, b|
      db = Math.sqrt(((b[0][0] - best.x)**2) + ((b[0][1] - best.y)**2))
      da = Math.sqrt(((a[0][0] - best.x)**2) + ((a[0][1] - best.y)**2))

      da <=> db
    end
  end
end

zapped = []
until zapped.size == (asteroids.size - 1) do
  quad_asteroids.each do |quad|
    angles = quad[:asteroids].keys.sort do |a, b|
      if a.to_s =~ /[a-z]/ && b.to_s !~ /[a-z]/
        -1
      elsif b.to_s =~ /[a-z]/ && a.to_s !~ /[a-z]/
        1
      elsif quad[:quadrant] == :ne
        b <=> a
      elsif quad[:quadrant] == :se
        a <=> b
      elsif quad[:quadrant] == :nw
        a <=> b
      elsif quad[:quadrant] == :sw
        b <=> a
      else
        0
      end
    end

    angles.each do |a|
      # puts "---"
      # puts "angle: #{a} (#{a.class})"
      # puts "keys: #{quad[:asteroids].keys.map { |k| [k, k.class] }.inspect }"
      # puts quad[:asteroids].inspect
      zapped.push(quad[:asteroids][a].shift)
      zapped.compact!
    end
  end
end

puts "1st: #{zapped[0]}"
puts "2nd: #{zapped[1]}"
puts "3rd: #{zapped[2]}"
puts "10th: #{zapped[9]}"
puts "20th: #{zapped[19]}"
puts "50th: #{zapped[49]}"
puts "100th: #{zapped[99]}"
puts "199th: #{zapped[198]}"
puts "200th: #{zapped[199]}"
puts "201st: #{zapped[200]}"
puts "299th: #{zapped[298]}"
puts zapped.size

winner = zapped[199]
puts ((winner[0][0] * 100) + winner[0][1])
