
require 'gosu'
class WhackWindow < Gosu::Window
    def initialize
        super(800,600)
        self.caption = "Whack the Ruby"

        @gem = Gosu::Image.new('ruby.png')
        @hammer = Gosu::Image.new('ham.png')
        @x = 200
        @y = 200
        @width = 10
        @height = 10
        @velocity_x = 5
        @velocity_y = 5
        @hit = 0
        @visible = 0
        @font
    end
    def update
        @x += @velocity_x
        @y += @velocity_y
        @velocity_x *= -1 if @x + width/2>800 || @x<0      
        @velocity_y *= -1 if @y + width/2>600 || @y<0
        @visible -= 1
        @visible = 30  if @visible < -10 && rand < 0.01
    end
    def button_down(id)
        if(id == Gosu::MsLeft)
            if(Gosu.distance(mouse_x,mouse_y,@x,@y) < 10) && @visible >=0
                @hit == 1
            else 
                @hit == 0
            end
        end
    end

    def draw
        if (@visible > 0)
            @gem.draw(@x,@y,1)
        end
        @hammer.draw(mouse_x-100,mouse_y-150,1)
        if (@hit == 0)
            c = Gosu::Color::NONE
        elsif (@hit == 1)
            c = Gosu::Color::GREEN
        else
            c = Gosu::Color::RED
        end
        draw_quad(0,0,c,800,0,c,800,600,c,0,600,c)
    end
end
x = WhackWindow.new()
x.show()