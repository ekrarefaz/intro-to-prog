require 'gosu'

class WhackARuby < Gosu::Window
    def initialize
        super(800,600)
        self.caption = 'Whack A Ruby'
        @ruby_image = Gosu::Image.new('./ruby.png')
        @hammer_image = Gosu::Image.new('./hammer.png')
        @x = 200
        @y = 200
        @width = 150
        @height = 150
        @velocity_x = 5
        @velocity_y = 5
        @visible = 30
    end

    def draw
        if @visible > 1
            @ruby_image.draw(@x,@y,1)
        end
        @hammer_image.draw(mouse_x - 50,mouse_y - 50,1)

        if @hit == 1 
            draw_rect(0, 0, 800, 600, Gosu::Color::GREEN, z = 0, mode = :default)
        end
    end

    def update
        @x += @velocity_x
        @y += @velocity_y
        @velocity_x *= -1 if @x > 800 || @x<0      
        @velocity_y *= -1 if @y > 600 || @y<0
        @visible -= 1
        @visible = 30 if @visible < -10 && rand < 0.01
    end

    def button_down(id)
        if (id == Gosu::MsLeft)
            if Gosu.distance(mouse_x, mouse_y, @x, @y) < 50 && @visible >= 0
            @hit = 1
            else
            @hit = -1
            end
        end
    end
end



window = WhackARuby.new()
window.show()