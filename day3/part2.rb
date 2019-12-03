#!/usr/bin/env ruby

require 'set'

grids = []
ARGF.each do |line|
  x = 0
  y = 0
  s = 0
  grid = {}
  line.chomp.split(",").each do |instruction|
    direction = instruction[0]
    n = instruction[1..-1].to_i
    n.times do
      s += 1
      if direction == 'L'
        x -= 1
      elsif direction == 'R'
        x += 1
      elsif direction == 'U'
        y += 1
      elsif direction == 'D'
        y -= 1
      end
      grid[[x,y]] = s unless grid.has_key?([x,y])
    end
  end
  grids << grid
end

best = nil
keys = (grids[0].keys + grids[1].keys).uniq
keys.each do |k|
  if grids[0].has_key?(k) && grids[1].has_key?(k)
    sum = grids[0][k] + grids[1][k]
    if best.nil?
      best = sum
    else
      best = sum if sum < best
    end
  end
end

puts best
