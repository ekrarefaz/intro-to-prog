require 'gosu'
require_relative 'input_functions'
require_relative 'album_functions'

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end 


class ArtWork
  attr_accessor :bmp 
  def initialize (file)
    @bmp = Gosu::Image.new(file)
  end
end

class MainPlayer < Gosu::Window
  WIDTH = 800
  HEIGHT = 640
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Music Player'
    @window = self
    @font = Gosu::Font.new(30)
    @background = Gosu::Image.new('manuel-sardo-dZOFaMG-0Q0-unsplash.jpg')
    @scene = :start
    @albums = []

  end

  def draw
    draw_back
  end

  def draw_start
    @background.draw_as_quad(0, 0, 0xffffffff, @window.width, 0, 0xffffffff, @window.width, @window.height, 0xffffffff, 0, @window.height, 0xffffffff, 0)
  end

  def draw_albums
    

  end
end


window = MainPlayer.new
window.show
  