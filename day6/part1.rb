#!/usr/bin/env ruby

input = File.read(ARGV[0]).split("\n")

@orbits = {}
@orbital_pairs = input.map {|l| l.split(")") }.sort
@orbital_pairs.each do |orbited, orbiter|
  @orbits[orbited] ||= []
  @orbits[orbited] << orbiter
end

def starwalk(planet = "COM", depth = 1)
  count = 0
  @orbits[planet].each do |p|
    count += (1 * depth)
    if @orbits.has_key?(p)
      count += starwalk(p, depth + 1)
    end
  end

  return count
end

puts starwalk
