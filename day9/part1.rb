#!/usr/bin/env ruby

class Intcode
  OPCODES = {
    1 => {
      :params => [:input, :input, :write],
      :op => lambda do |lhs, rhs, store|
        @memory[store] = lhs + rhs
      end
    },
    2 => {
      :params => [:input, :input, :write],
      :op => lambda do |lhs, rhs, store|
        @memory[store] = lhs * rhs
      end
    },
    3 => {
      :params => [:write],
      :op => lambda do |addr|
        if @stdin.tty?
          # This is cheating, for now. We know that @stdin
          # is a tty, and thus there is a human attached.
          # We presume that STDOUT will also have a human
          # attached regardless of @stdout, and thus should ask
          # the human for input via STDOUT.
          STDOUT.print "Input  => "
        end
        @memory[addr] = @stdin.gets.chomp.to_i
      end
    },
    4 => {
      :params => [:input],
      :op => lambda do |val|
        if @stdout.tty?
          @stdout.puts "Output => #{val}"
        else
          @stdout.puts val
        end
      end
    },
    5 => {
      :params => [:input, :input],
      :op => lambda do |value, pointer|
        if value != 0
          @instruction_pointer = pointer
        end
      end
    },
    6 => {
      :params => [:input, :input],
      :op => lambda do |value, pointer|
        if value == 0
          @instruction_pointer = pointer
        end
      end
    },
    7 => {
      :params => [:input, :input, :write],
      :op => lambda do |lhs, rhs, store|
        if lhs < rhs
          @memory[store] = 1
        else
          @memory[store] = 0
        end
      end
    },
    8 => {
      :params => [:input, :input, :write],
      :op => lambda do |lhs, rhs, store|
        if lhs == rhs
          @memory[store] = 1
        else
          @memory[store] = 0
        end
      end
    },
    9 => {
      :params => [:input],
      :op => lambda do |val|
        @relative_base += val
      end
    },
  }
  OPCODE_HALT = 99

  PARAM_MODE_POSITIONAL = 0
  PARAM_MODE_IMMEDIATE  = 1
  PARAM_MODE_RELATIVE   = 2

  attr_reader :memory
  attr_accessor :stdin
  attr_accessor :stdout
  def initialize(program)
    @memory = IntcodeMemory.new(program.split(",").map(&:to_i))
    @stdin = STDIN
    @stdout = STDOUT
    @instruction_pointer = 0
    @relative_base = 0
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
      relative_base: #{@relative_base}
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
            elsif mode == PARAM_MODE_RELATIVE
              val_idx = @memory[param_idx] + @relative_base
              val = @memory[val_idx]
              debug <<~EOS
                positional parameter:
                  idx:     #{param_idx}
                  val_idx: #{val_idx}
                  val:     #{val}
              EOS
              parameters.push val
            else # mode == PARAM_MODE_POSITIONAL
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
            elsif mode == PARAM_MODE_RELATIVE
              val_idx = @memory[param_idx] + @relative_base
              debug <<~EOS
                positional write parameter:
                  idx:     #{param_idx}
                  val_idx: #{val_idx}
              EOS
              parameters.push val_idx
            else # mode == PARAM_MODE_POSITIONAL
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

class IntcodeMemory
  def initialize(program)
    @memory = program
  end

  def [](idx)
    @memory[idx] || 0
  end

  def []=(idx, val)
    @memory[idx] = val
  end
end

program = File.read(ARGV[0])
computer = Intcode.new(program)
computer.run
