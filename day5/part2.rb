#!/usr/bin/env ruby

class Intcode
  OPCODES = {
    1 => {
      :params => [:input, :input, :write],
      :op => lambda { |lhs, rhs, store|
        @memory[store] = lhs + rhs
      }
    },
    2 => {
      :params => [:input, :input, :write],
      :op => lambda { |lhs, rhs, store|
        @memory[store] = lhs * rhs
      }
    },
    3 => {
      :params => [:write],
      :op => lambda { |addr|
        print "Input  => "
        @memory[addr] = STDIN.gets.chomp.to_i
      }
    },
    4 => {
      :params => [:input],
      :op => lambda { |val| puts "Output => #{val}" }
    },
    5 => {
      :params => [:input, :input],
      :op => lambda { |value, pointer|
        if value != 0
          @instruction_pointer = pointer
        end
      }
    },
    6 => {
      :params => [:input, :input],
      :op => lambda { |value, pointer|
        if value == 0
          @instruction_pointer = pointer
        end
      }
    },
    7 => {
      :params => [:input, :input, :write],
      :op => lambda { |lhs, rhs, store|
        if lhs < rhs
          @memory[store] = 1
        else
          @memory[store] = 0
        end
      }
    },
    8 => {
      :params => [:input, :input, :write],
      :op => lambda { |lhs, rhs, store|
        if lhs == rhs
          @memory[store] = 1
        else
          @memory[store] = 0
        end
      }
    },
  }
  OPCODE_HALT = 99

  PARAM_MODE_POSITIONAL = 0
  PARAM_MODE_IMMEDIATE  = 1

  attr_reader :memory
  def initialize(input)
    @memory = input.split(",").map(&:to_i)
    @instruction_pointer = 0
  end

  def run
    loop do
      instruction = get_instruction
      opcode = get_opcode(instruction)
      pointer = @instruction_pointer
      debug <<~EOS

      ------------------
      memory: #{@memory.inspect}
      instruction_pointer: #{@instruction_pointer}
      instruction: #{instruction}
      opcode: #{opcode}

      EOS

      if opcode == OPCODE_HALT
        return
      elsif OPCODES.has_key?(opcode)
        parameters = []
        modes = parameter_modes(instruction)
        debug "parameter_modes: #{modes.inspect}"

        OPCODES[opcode][:params].each_with_index do |type, idx|
          param_idx = @instruction_pointer + idx + 1
          mode = modes[idx] || PARAM_MODE_POSITIONAL
          case type
          when :input
            if mode == PARAM_MODE_IMMEDIATE
              val = @memory[param_idx]
              debug <<~EOS
                immediate parameter:
                  idx: #{param_idx}
                  val: #{val}
              EOS
              parameters.push val
            else
              val_idx = @memory[param_idx]
              val = @memory[val_idx]
              debug <<~EOS
                positional parameter:
                  idx:     #{param_idx}
                  val_idx: #{val_idx}
                  val:     #{val}
              EOS
              parameters.push val
            end
          when :write
            if mode == PARAM_MODE_IMMEDIATE
              abort "Error - write param is in immediate mode"
            else
              val_idx = @memory[param_idx]
              debug <<~EOS
                positional write parameter:
                  idx:     #{param_idx}
                  val_idx: #{val_idx}
              EOS
              parameters.push val_idx
            end
          end
        end

        self.instance_exec(*parameters, &OPCODES[opcode][:op])
        unless pointer != @instruction_pointer
          advance = OPCODES[opcode][:params].size + 1
          @instruction_pointer += advance
        end
      else
        abort <<~EOS
        Unknown opcode #{opcode}, position #{@instruction_pointer}
        EOS
      end
    end
  end

  private
  def get_instruction
    @memory[@instruction_pointer]
  end

  def get_opcode(instruction)
    instruction % 100
  end

  def parameter_modes(instruction)
    modes = []
    divisor = 100
    loop do
      break if instruction % divisor == instruction
      modes << (instruction / divisor) % 10

      divisor *= 10
    end

    modes
  end

  def debug(str)
    puts str if ENV['DEBUG']
  end
end

input = File.read(ARGV[0])
computer = Intcode.new(input)
computer.run
