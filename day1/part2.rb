#!/usr/bin/env ruby

total_fuel = 0

ARGF.each do |line|
  input = line.to_i
  while input > 0 do
    required = (input / 3) - 2
    if required > 0
      total_fuel += required
    end
    input = required
  end
end

puts total_fuel
