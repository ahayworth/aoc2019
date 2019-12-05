#!/usr/bin/env ruby

lower_bound = ARGV[0].to_i
upper_bound = ARGV[1].to_i

passed = 0
(lower_bound..upper_bound).each do |candidate|
  nums = candidate.to_s.chars.map(&:to_i)

  next if nums.length != 6
  split_nums = nums.slice_when { |i,j| i != j }.to_a
  next if split_nums.size == nums.size
  next unless split_nums.any? { |n| n.size == 2 }
  next if nums.slice_when { |i,j| i <= j }.to_a.size <  nums.size

  passed += 1
end

puts passed
