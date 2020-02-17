#!/usr/bin/env ruby

require_relative "../lib/intcode.rb"


BLACK = 0
WHITE = 1

UP    = 90
DOWN  = 270
LEFT  = 180
RIGHT = 0

@direction = 90
@position = [0,0]
@grid = {
  [0,0] => BLACK
}

program = File.read(ARGV[0])
computer = Intcode.new(program)
computer.stdin, @stdin   = IO.pipe
@stdout, computer.stdout = IO.pipe

@computer_thread = Thread.new { computer.run }
@io_thread = Thread.new do
  loop do
    if @grid[@position].nil?
      @grid[@position] = BLACK
    end

    puts "sending to @stdin"
    @stdin.puts @grid[@position]
    puts "waiting on @stdout"
    x = @stdout.gets.chomp.to_i
    puts "got: #{x}"
    @grid[@position] = x #@stdout.gets.chomp.to_i

    puts "waiting on @stdout"
    direction = @stdout.gets.chomp
    puts "got: #{direction}"
    @direction += (direction == 0 ? 90 : -90)
    if @direction > DOWN
      @direction = RIGHT
    elsif @direction < RIGHT
      @direction = UP
    end

    case @direction
    when UP    then @position[1] += 1
    when DOWN  then @position[1] -= 1
    when LEFT  then @position[0] -= 1
    when RIGHT then @position[0] += 1
    end

    break if @io_thread.status == false
  end
end

[@computer_thread, @io_thread].map(&:join)
puts @grid.inspect
