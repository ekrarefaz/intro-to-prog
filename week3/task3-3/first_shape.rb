require "rubygems"
require "gosu"
#require "./circle.rb"

module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end
  
class DemoWindow < Gosu::Window
    def initialize
      super(800, 600)
    end
    '''def draw
        img = Gosu::Image.new(Circle.new(50))
        img.draw(200, 200, ZOrder::TOP, 0.5, 1.0, Gosu::Color::RED)
    end'''
end

window = DemoWindow.new
window.show