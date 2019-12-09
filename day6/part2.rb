#!/usr/bin/env ruby

input = File.read(ARGV[0]).split("\n")

@counts = []

def starwalk(planet, count = 0, visited = [])
  # puts "#{count}: #{planet}"
  visited << planet

  destinations = []
  destinations << @orbiters[planet]
  destinations << @orbited[planet]
  destinations = destinations.flatten.compact
  destinations.reject! { |p| p == planet || visited.include?(p) }

  # puts "destinations: #{destinations.inspect}"
  # puts "visited: #{visited.inspect}"
  destinations.each do |p|
    # puts "looking at #{p}"
    if p == "SAN"
      puts "SANTA"
      @counts << count
    elsif p != planet
      starwalk(p, count + 1, visited.dup)
    end
  end

  return count
end

@orbited  = {}
@orbiters = {}
@orbital_pairs = input.map {|l| l.split(")") }.sort
@orbital_pairs.each do |orbited, orbiter|
  @orbited[orbited] ||= []
  @orbited[orbited] << orbiter
  @orbiters[orbiter] = orbited

end

starwalk(@orbiters["YOU"])
puts @counts.inspect
