#!/usr/bin/env ruby

require 'set'

grids = []
ARGF.each do |line|
  x = 0
  y = 0
  points = Set.new
  line.chomp.split(",").each do |instruction|
    direction = instruction[0]
    n = instruction[1..-1].to_i
    n.times do
      if direction == 'L'
        x -= 1
      elsif direction == 'R'
        x += 1
      elsif direction == 'U'
        y += 1
      elsif direction == 'D'
        y -= 1
      end
      points << [x, y]
    end
  end
  grids << points
end

overlaps = grids[0] & grids[1]
closest = overlaps.to_a.sort {|a, b| (a[0].abs + a[1].abs) <=> (b[0].abs + b[1].abs) }.first
puts closest[0].abs + closest[1].abs
