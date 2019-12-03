#!/usr/bin/env ruby

puts ARGF.map(&:to_i).reduce(0) { |a, i| a += (i / 3) - 2 }
