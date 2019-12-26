#!/usr/bin/env ruby

WIDTH  = 25
HEIGHT = 6

class SpaceImage
  attr_reader :layers
  def initialize(data, width, height)
    @layers = []

    pixels = data.split("").map(&:to_i)
    pixels.each_slice(width * height) do |slice|
      @layers.push(SpaceImageLayer.new(slice, width))
    end
  end
end

class SpaceImageLayer
  attr_reader :data
  def initialize(pixels, width)
    @data = []
    @data.push []

    pixels.each do |pixel|
      if @data.last.size >= width
        @data.push []
      end

      @data.last.push pixel
    end
  end
end

data = File.read(ARGV[0]).chomp
image = SpaceImage.new(data, WIDTH, HEIGHT)

sorted_layers = image.layers.sort do |a,b|
  a.data.flatten.count(0) <=> b.data.flatten.count(0)
end

layer = sorted_layers.first
puts layer.data.flatten.count(1) * layer.data.flatten.count(2)
