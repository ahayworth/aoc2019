#!/usr/bin/env ruby

WIDTH  = 25
HEIGHT = 6

class SpaceImage
  attr_reader :layers
  attr_reader :data
  attr_reader :width
  attr_reader :height

  def initialize(data, width, height)
    @layers = []
    @width  = width
    @height = height

    if data.class == String
      pixels = data.split("").map(&:to_i)
    else
      pixels = data
    end

    pixels.each_slice(width * height) do |slice|
      @layers.push(SpaceImageLayer.new(slice, width))
    end
  end

  def flatten
    new_layer = @layers[1..-1].reduce(@layers[0]) do |a, l|
      a + l
    end
    SpaceImage.new(new_layer.data.flatten, @width, @height)
  end

  def to_s
    layer = (@layers.size > 1 ? flatten.layers[0] : @layers[0])
    layer.to_s
  end
end

class SpaceImageLayer
  attr_reader :data
  attr_reader :width
  def initialize(pixels, width)
    @data = []
    @data.push []

    @width = width

    pixels.each do |pixel|
      if @data.last.size >= width
        @data.push []
      end

      @data.last.push SpaceImagePixel.new(pixel)
    end
  end

  def +(other)
    new_data = []
    @data.flatten.zip(other.data.flatten) do |p, op|
      new_data << p + op
    end
    SpaceImageLayer.new(new_data, @width)
  end

  def to_s
    @data.map { |row| row.map(&:to_s).join }.join("\n")
  end
end

class SpaceImagePixel
  BLACK = 0
  WHITE = 1
  TRANS = 2

  attr_reader :value
  def initialize(value)
    if value.class == SpaceImagePixel
      @value = value.value
    else
      @value = value
    end
  end

  def +(other)
    new_val = (@value == TRANS ? other : @value)
    SpaceImagePixel.new(new_val)
  end

  def to_s
    case @value
    when BLACK
      "▉"
    when WHITE
      "░"
    end
  end
end

data = File.read(ARGV[0]).chomp
image = SpaceImage.new(data, WIDTH, HEIGHT)
puts image.to_s
