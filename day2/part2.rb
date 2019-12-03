#!/usr/bin/env ruby

OP_ADD  = 1
OP_MULT = 2
OP_HALT = 99

def run(memory)
  instruction_pointer = 0

  loop do
    case memory[instruction_pointer]
    when OP_ADD
      lhs = memory[memory[instruction_pointer + 1]]
      rhs = memory[memory[instruction_pointer + 2]]
      result_idx = memory[instruction_pointer + 3]
      memory[result_idx] = lhs + rhs
      instruction_pointer += 4
    when OP_MULT
      lhs = memory[memory[instruction_pointer + 1]]
      rhs = memory[memory[instruction_pointer + 2]]
      result_idx = memory[instruction_pointer + 3]
      memory[result_idx] = lhs * rhs
      instruction_pointer += 4
    when OP_HALT
      break
    else
      abort "Unknown op code #{memory[instruction_pointer]} found at position #{instruction_pointer}"
    end
  end
  return memory
end

program = ARGF.read.split(",").map(&:to_i)

(0..99).each do |noun|
  (0..99).each do |verb|
    memory = program.dup
    memory[1] = noun
    memory[2] = verb
    memory = run(memory)

    if memory[0] == 19690720
      puts <<~EOF
        noun: #{noun}
        verb: #{verb}
        answer: #{100 * noun + verb}
      EOF
    end
  end
end
