#!/usr/bin/env ruby

OP_ADD  = 1
OP_MULT = 2
OP_HALT = 99

pointer = 0
registers = ARGF.read.split(",").map(&:to_i)

registers[1] = 12
registers[2] = 2

loop do
  case registers[pointer]
  when OP_ADD
    lhs = registers[registers[pointer + 1]]
    rhs = registers[registers[pointer + 2]]
    result_idx = registers[pointer + 3]
    registers[result_idx] = lhs + rhs
    pointer += 4
  when OP_MULT
    lhs = registers[registers[pointer + 1]]
    rhs = registers[registers[pointer + 2]]
    result_idx = registers[pointer + 3]
    registers[result_idx] = lhs * rhs
    pointer += 4
  when OP_HALT
    break
  else
    abort "Unknown op code #{registers[pointer]} found at position #{pointer}"
  end
end
puts registers.inspect
