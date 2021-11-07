# Author: Ekrar Uddin Mohammed Efaz
# StudentID: 103494172
# Program Name: Super Extented Music Player
# Attemping Grade: HD
# required dependencies: 'gosu', 'optparse', 'tcl/tk', 'input_functions.rb', 'colors.rb'
# *all the relative dependencies can be found in .lib folder in this directory*


require 'gosu'
require 'optparse'
require 'tk'
# require_relative
require_relative './.lib/input_functions'
require_relative 'album_functions'

#Works on Linux with vlc installed 
#For Mac an alias must set to vlc system call via terminal
#Following commands for OSX:
#echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#echo "alias cvlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#Windows not supported
require "vlc-client" #https://github.com/mguinada/vlc-client

TOP_COLOR = Gosu::Color.new(0xFF183929)
UI_COLOR = Gosu::Color.new(0xFFffffff)
SCOLOR = Gosu::Color.new(0xFF0e3d5e)


#zorder enumeration
module ZOrder
  BACKGROUND, PLAYER, UI = *0..2  
end

#genre enumeration
module Genre
  POP, CLASSIC, JAZZ, ROCK, METAL = *1..5
end

#global variable for list of genre
GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock', 'Metal']

#Class for album cover/artwork
class ArtWork
	attr_accessor :bmp
	def initialize(file)
		@bmp = Gosu::Image.new(file)
	end
end

#album class
class Album 
  attr_accessor :id, :title, :artist, :artwork, :genre , :tracks
  def initialize(id, title, artist, artwork, genre, tracks)
      @id = id
      @title = title 
      @artist = artist
      @artwork = artwork
      @genre = genre
      @tracks = tracks
  end
end

#track class
class Track
  attr_accessor :name, :location
  def initialize(name, location)
      @location = location
      @name = name 
  end
end

#favorites class
class Favorites 
  attr_accessor :name, :artist, :location
  def initialize(name, location, artist)
    @name = name
    @location = location 
    @artist = artist
  end
end

#GOSU MAIN PLAYER CLASS
class MusicPlayerMain < Gosu::Window
  WIDTH = 820
  HEIGHT = 600
	def initialize
	  super WIDTH, HEIGHT
	  self.caption = "Music Player"

    #scene control variables
    @scene = :menu1
    @album_count = nil

    #reading album file with ruby tk
    root = TkRoot.new
    root.title = "window"
    @filename = Tk::getOpenFile
    music_file = open(@filename,"r")
    @albums = read_albums(music_file)
    root.destroy() 
    #print(@albums)
    
    #instance variables for album absolute album positions
    @favorites_position = [50,280,750,395]
    
    @album1_position = [50, 50, 250 , 250]
    @album2_position = [300, 50, 450, 250]
    @album3_position = [550, 50, 700, 250]

    @album4_position = [50, 50, 250, 250]
    @album5_position = [300, 50, 450, 250]
    @album6_position = [550, 50, 700, 250]

    @album7_position = [50, 50, 250, 250]
    @album8_position = [300, 50, 450, 250]
    @album9_position = [550, 50, 700, 250]

    #bunch of empty arrays declared for later use
    @favorites_list = [] #array for favorite tracks object
    @favorite_dump = [] #array for favorite tracks name
    @genre_tracklist = [] #array for tracks of selected genre

    #array holding all the album positions
    @albums_position = [@album1_position,@album2_position,@album3_position,@album4_position,@album5_position,@album6_position,@album7_position,@album8_position]
    
    #current track and current album status variables
    @current_album = nil
    @current_album_track_count = nil
    @current_track_repeat = false
    @current_track_location = nil
    @current_track = nil

    #music control variables
    @track_playing = nil
    @music = nil
    @volume = 1
	end

                                                    #####################
                                                    ## 1 ALBUM READING ##
                                                    #####################

  #keep all tracks sorted by genre
  def read_tracks_by_genre(selected_genre)
    i = 0
    while (i < @albums.length)
      k = 0
      if(selected_genre == @albums[i].genre)
        puts @albums[i].tracks
        k = 0
        while(k < @albums[i].tracks.length)
          @genre_tracklist << @albums[i].tracks[k]
          k += 1
        end
        i += 1
      else
        i += 1
      end
    end
  end


  #nothing in the update function all events handled by mouse clicked
	def update
	end

                                              #####################
                                              ## Drawing Modules ##
                                              #####################

  #draw the background
	def draw_background
    Gosu.draw_rect(0,0,WIDTH,HEIGHT,TOP_COLOR,ZOrder::BACKGROUND,:default)
  end


  #draw next and previous :menu paging button
  def draw_favorites_box()
    Gosu.draw_rect(50, 280, 700, 115, Gosu::Color::BLACK, ZOrder::UI,:default)
    Gosu::Font.new(40).draw("Favorites Playlist",265,320,ZOrder::UI)
  end


  # show genre button
  def draw_genre_box()
    Gosu.draw_rect(50, 410, 700, 115, Gosu::Color::BLACK, ZOrder::UI,:default)
    Gosu::Font.new(40).draw("Genre Sort",300,450,ZOrder::UI)
  end


  # close button for the application
  def close_box()
    Gosu.draw_rect(775,15,20,20,Gosu::Color::BLACK, ZOrder::UI, :default)
    Gosu::Font.new(20).draw("x",780,15,ZOrder::UI)
  end


  #genre sort menu
  def genre_sort_menu()
    y = 105
    i = 1
    while(i < GENRE_NAMES.length)
      Gosu.draw_rect(55,y,150,50,Gosu::Color::BLACK, ZOrder::UI, :default)
      Gosu::Font.new(30).draw("#{GENRE_NAMES[i]}",95,y,ZOrder::UI)
      y += 100
      i += 1
    end
  end


  #draw next and previous buttons for paging
  def draw_page_button()
    if @scene == :menu1 || :menu2 || :menu3
      # Gosu.draw_rect(760, 50, 50, 200, Gosu::Color::BLACK, ZOrder::UI,:default)
      Gosu::Font.new(50).draw("<",5,125,ZOrder::UI)
      Gosu::Font.new(50).draw(">",770,125,ZOrder::UI)
    end
  end


  #draw the volume rocker button at different volume
  def draw_volume_rocker()
    Gosu.draw_rect(740, 150, 50, 300, Gosu::Color::BLACK, ZOrder::UI,:default)
    if @volume == 1.0
      Gosu.draw_rect(750, 160, 30, 280, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.25
      Gosu.draw_rect(750, 380, 30, 60, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.5
      Gosu.draw_rect(750, 310, 30, 130, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.75
      Gosu.draw_rect(750, 240, 30, 200, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.0
      Gosu.draw_rect(750, 160, 30, 0, UI_COLOR, ZOrder::UI,:default)
    end
  end


  #draw the button to open vlc external player
  def external_player_button()
    @external_button = Gosu::Image.new('./media/vlc.png')
    @external_button.draw(560, 480, ZOrder::UI,0.08,0.08)
  end


  #draw the back/return to main menu button
  def draw_back_button()
    Gosu::Font.new(20).draw("< BACK", 50, 50, ZOrder::UI)
  end

  
  #Toggle-able Play/Pause Button
  def draw_play_pause_button()
    if @track_playing == nil
      @play = Gosu::Image.new('./media/play.png')
      @play.draw(360, 480, ZOrder::UI, 0.05,0.05)
    elsif @track_playing
      @pause = Gosu::Image.new('./media/pause.png')
      @pause.draw(360, 495, ZOrder::UI, 0.1,0.1)
    elsif !@track_playing
      @play = Gosu::Image.new('./media/play.png')
      @play.draw(360, 480, ZOrder::UI, 0.05,0.05)
    end
  end


  #Forward and backward button
  def draw_forward_backward_button()
    @forward = Gosu::Image.new('./media/forward.png')
    @forward.draw(460, 495, ZOrder::UI, 0.05,0.05)
    @forward.draw_rot(280,495,ZOrder::UI, 180, 1, 1, scale_x = 0.05, scale_y = 0.05)
  end


  #Toggle-able Repeat Button
  def draw_repeat_button()
    if @current_track_repeat
      @repeat_active = Gosu::Image.new('./media/repeat1.png')
      @repeat_active.draw(180, 495, ZOrder::UI, 0.09, 0.09)
    else
      @repeat_inactive = Gosu::Image.new('./media/repeat_inactive.png')
      @repeat_inactive.draw(180, 495, ZOrder::UI, 0.25, 0.25)
    end
  end

  
  #Toggle-able Favorite Button Click
  def draw_favorite_toggle_button()
    if(@favorite_dump.include? @playing_track_name)
      @favorite_active = Gosu::Image.new('./media/favorite_active.jpeg')
      @favorite_active.draw(70,495,ZOrder::UI,0.26,0.26)
    else
      @favorite = Gosu::Image.new('./media/favorite_inactive.png')
      @favorite.draw(70,495,ZOrder::UI, 0.26,0.26)
    end
  end


  #Draw Muted Button
  def draw_muted_button()
    if @volume == 0.0
      @muted = Gosu::Image.new('./media/muted.png')
      @muted.draw(750,480,ZOrder::UI, 0.05,0.05)
    end
  end


  #draw player buttons
  def draw_buttons()
    #draw player control box
    Gosu.draw_rect(0, 450, 820, 250, UI_COLOR,ZOrder::PLAYER, :default)

    #Toggle-able Play/Pause Button
    draw_play_pause_button()

    #Forward Backward button
    draw_forward_backward_button()

    #Toggle-able Repeat Button
    draw_repeat_button()

    #Toggle-able Favorite Button Click
    draw_favorite_toggle_button()

    #Draw Muted Button
    draw_muted_button()
  end


  #display tracks for selected album
  def display_tracks()
    track_y_position = 100
    for track in @albums[@current_album].tracks
      Gosu::Font.new(20).draw(track.name, 400, track_y_position, ZOrder::UI)
      track_y_position += 35
    end
  end


  # display tracks in genre sort menu
  def display_tracks_by_genre()
    track_y_postion = 100
    if (@genre_tracklist.length != 0)
      for track in @genre_tracklist
        Gosu::Font.new(20).draw(track.name, 400, track_y_postion, ZOrder::UI)
        track_y_postion += 35
      end
    else
      Gosu::Font.new(20).draw("No Tracks", 400, 100, ZOrder::UI)
    end
  end


  #draw the favorite albums tracks
  def display_favorite_tracks()
    track_y_position = 100
    i = 0
    while ( i < @favorites_list.length)
      Gosu.draw_rect(0,track_y_position, 800, 30, Gosu::Color::BLACK,ZOrder::PLAYER, :default)
      Gosu::Font.new(30).draw("#{@favorites_list[i].name}", 150, track_y_position, ZOrder::UI)
      track_y_position += 35
      i += 1
    end
  end


  #text display the playing track
  def display_playing_track
    if @track_playing
      message = "Playing #{@playing_track_name}"
      Gosu::Font.new(30).draw(message, 350, 370, ZOrder::UI)
    end
  end


  #Draws the current album selected in :player mode
  def draw_album(album)
    x = 20
    y = 100
    if @current_album != "favorites"
      current_album_artwork = Gosu::Image.new(@albums[@current_album].artwork.chomp)
      current_album_artwork.draw(x, y, ZOrder::UI,1,1)
    end
    display_tracks()
  end


  #draw all the albums in the respective :menu1/:menu2 page
  def draw_albums(albums)
    if @scene == :menu1
      (0..2).each do |i|
        album_artwork = Gosu::Image.new(albums[i].artwork.chomp)
        album_artwork.draw(@albums_position[i][0],@albums_position[i][1],ZOrder::UI, 1,1)
      end
    elsif @scene == :menu2
        (3..5).each do |i|
          album_artwork = Gosu::Image.new(albums[i].artwork.chomp)
          album_artwork.draw(@albums_position[i][0],@albums_position[i][1],ZOrder::UI, 0.68,0.68)
        end
    elsif @scene == :menu3
      i = 6
      until (i == @albums.length) do
        album_artwork = Gosu::Image.new(albums[i].artwork.chomp)
        album_artwork.draw(@albums_position[i][0],@albums_position[i][1],ZOrder::UI, 0.68,0.68)
        i += 1
      end
    end
  end


  #mouse hover over albums effect
  def mouse_over_album()
    i = 0
    while (i < @albums.length)
      if ((mouse_x > @albums_position[i][0] && mouse_x < @albums_position[i][2]) && ( mouse_y > @albums_position[i][1] && mouse_y < @albums_position[i][3]))
        Gosu.draw_rect(@albums_position[i][0]+50 ,40, 100, 5, UI_COLOR, ZOrder::PLAYER, mode=:default)
      end
      i += 1
    end
  end


  #mouse hover over options effect
  def mouse_over_favorites()
    if ((mouse_x > @favorites_position[0] && mouse_x < @favorites_position[2]) && ( mouse_y > @favorites_position[1] && mouse_y < @favorites_position[3]))
      Gosu.draw_rect(50, 280, 700, 115,SCOLOR,ZOrder::UI,:default)
      Gosu::Font.new(40).draw("Favorites Playlist",265,320,ZOrder::UI)
    end
  end


  def mouse_over_genrebox()
    if ((mouse_x > 50 && mouse_x < 750) && ( mouse_y > 410 && mouse_y < 525))
      Gosu.draw_rect(50, 410, 700, 115,SCOLOR,ZOrder::UI,:default)
      Gosu::Font.new(40).draw("Genre Sort",300,450,ZOrder::UI)
    end
  end


  # mouse hover effects
  def mouse_over_menu()
    mouse_over_album()
    mouse_over_favorites()
    mouse_over_genrebox()
  end


  # draws albums
  def draw_menu(albums)
    draw_albums(albums)
  end


  #DRAW FOR ALL SCENES
	def draw
    close_box()
    case @scene
      #draw actions for :menu scene
      when :menu1
        # draw background
        draw_background()

        #draw menu1 albums
        draw_menu(@albums)

        #draw favorites option
        draw_favorites_box()

        #draw genre option
        draw_genre_box()

        #draw the paging button
        draw_page_button()

        #mouse hover effect function
        mouse_over_menu()

        #COORDINATES DEBUG
        #Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        #Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
      when :menu2
        #draw background
        draw_background() 
        
        #draw albums for menu2
        if (@albums.length > 3)
          draw_menu(@albums)
        else
          Gosu::Font.new(30).draw("NO ALBUMS",200,200,ZOrder::UI)
        end
        
        #draw favorites option
        draw_favorites_box()

        #draw genre option
        draw_genre_box()

        #draw paging buttons
        draw_page_button()

        #mouse hover effects
        mouse_over_menu()

        #COORDINATES DEBUG
        #Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        #Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI
      when :menu3
        #draw background
        draw_background() 
        if (@albums.length > 5)
          draw_menu(@albums)
        else
          Gosu::Font.new(30).draw("NO ALBUMS",200,200,ZOrder::UI)
        end

        #draw favorites option
        draw_favorites_box()

        #draw genre option
        draw_genre_box()

        #draw paging option
        draw_page_button()

        #mouse hover effects
        mouse_over_menu()

        #COORDINATES DEBUG
        #Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        #Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI
      when :genre_sort
        #draw background
        draw_background()

        #draw button to return to menu
        draw_back_button()

        #draw genre select buttons
        genre_sort_menu()

        #draw tracks for selected genre
        display_tracks_by_genre()

        #draw playing track
        display_playing_track()

      #draw actions for :player scene
      when :player
        #draw background
        draw_background()

        #check if the selected album is favorites album
        if @current_album != "favorites"
          draw_album(@albums[@current_album])
          draw_back_button()
          display_tracks()
        elsif @current_album == "favorites"
          draw_back_button()
          display_favorite_tracks()
        end

        #redirect to external player
        external_player_button()

        #draw playing track
        display_playing_track()

        #draw player control buttons
        draw_buttons()

        #draw volume rocker
        draw_volume_rocker()

        #COORDINATES DEBUG
        #Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        #Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
      end
	end


  #to show the cursor in program
 	def needs_cursor?; true; end

                                      ###################################
                                      ## CLICK EVENT HANDLER FUNCTIONS ##
                                      ###################################

  #determine which area was clicked
  def area_clicked(leftX, topY, rightX, bottomY)
    return (mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY)
  end
 

  # page through multiple album pages
  def menu_paging_click()
    if @scene == :menu1
      if area_clicked(770,50,796,250)
        @scene =  :menu2
      end
    elsif @scene == :menu2
      if area_clicked(0,50,30,250)
        @scene = :menu1
       elsif area_clicked(770,50,796,250)
        @scene = :menu3
      end
    elsif @scene == :menu3
      if area_clicked(0,50,30,250)
        @scene = :menu2
      end
    end
  end


  # select genre click event
  def select_genre()
    y = 105
    i = 1
    while (i < GENRE_NAMES.length)
      if area_clicked(55,y,150,y+50)
        @genre_tracklist.clear
        selected_genre = i
        read_tracks_by_genre(selected_genre)
        break
      else
        y += 100
        i += 1
      end
    end
  end


  # selecting track in genre sort menu
  def select_track_by_genre()
    xL = 400
    xR = 600
    yT = 100
    yB = 130
    i = 0
    while(i < @genre_tracklist.length)
      if area_clicked(xL,yT,xR,yB)
        play_track_by_genre(i)
        break
      else
        yT += 35
        yB += 30
        i += 1
      end

    end
  end


  #close application click
  def close_application()
    close() if area_clicked(775,15,795,45)
  end


  #favorites album click event
  def favorites_album_click()
    if area_clicked(@favorites_position[0],@favorites_position[1],@favorites_position[2],@favorites_position[3])
      @scene = :player
      @current_album = "favorites"
    end
  end


  #genre sorted menu click event
  def genre_sort_click()
    if area_clicked(50,415,750,525)
      @scene = :genre_sort
    end
  end


  #PLAY PAUSE BUTTON EVENT
  def play_pause_click()
    if @current_album != "favorites"
      if @track_playing == nil && area_clicked(373,493,422,545)
        track_playing = true
        @current_track = 0
        play_track(@current_track, @albums[@current_album])
      elsif @track_playing && area_clicked(373,493,422,545)
        @music.pause
        @track_playing = false
      elsif !@track_playing && area_clicked(373,493,422,545) 
        @music.play
        @track_playing = true
      end
    elsif @current_album == "favorites"
      if @favorites_list.length != 0 || @track_playing != nil
        if @track_playing == nil && area_clicked(373,493,422,545)
          track_playing = true
          @current_track = 0
          play_track(@current_track, @albums[@current_album])
        elsif @track_playing && area_clicked(373,493,422,545)
          @music.pause
          @track_playing = false
        elsif !@track_playing && area_clicked(373,493,422,545) 
          @music.play
          @track_playing = true
        end
      end
    end
  end

  
  #BACKWARD BUTTON
  def forward_backward_click()
    if @current_track == nil
      @current_track = 0
    else
      if(@track_playing && area_clicked(283,494,319,549))
        if (@current_track != 0)
          @current_track -= 1 #backward
          play_track(@current_track, @albums[@current_album])
        end
      #FORWARD BUTTON
      elsif (@track_playing && area_clicked(462,496,500,549))     
        if(@current_track < @current_album_track_count-1)
          @current_track += 1  #forward
          play_track(@current_track, @albums[@current_album])
        end
      end
    end
  end
  


  #VOLUME BUTTON EVENT
  def volume_click()
    if @track_playing && area_clicked(750,380,780,450)
      @music.volume = 0.25
      @volume = @music.volume
    elsif @track_playing && area_clicked(750,290,780,380)
      @music.volume = 0.5
      @volume = @music.volume
    elsif @track_playing && area_clicked(750,240,780,290)
      @music.volume = 0.75
      @volume = @music.volume
    elsif @track_playing && area_clicked(750,150,780,240)
      @music.volume = 1.0
      @volume = @music.volume
    end
  end


  #ADDING, REMOVING TO FAVORITES ALBUM
  def add_to_favorites()
    if(@current_album != "favorites")
      if (@track_playing && area_clicked(75,502,126,550))
        favorite_track_name = @albums[@current_album].tracks[@current_track].name
        print "working"

        #checks if already in favorite
        if @favorite_dump.include? favorite_track_name
          @favorite_dump.delete favorite_track_name
          i = 0
          while (i < @favorites_list.length)
            if @favorites_list[i].name == favorite_track_name
              @favorites_list.delete @favorites_list[i]
              break
            else
              i += 1
            end
          end
        else
          @favorite_dump << favorite_track_name
          favorite_track = Favorites.new(@albums[@current_album].tracks[@current_track].name, @albums[@current_album].tracks[@current_track].location, @albums[@current_album].artist)
          @favorites_list << favorite_track
        end
      end
    end
  end


  #REPEAT BUTTON EVENT (Loops the Current Song)
  def repeat_song()
    if @current_track_repeat 
      @current_track_repeat = false
    elsif !@current_track_repeat 
      @current_track_repeat = true
    end
  end

  def repeat_click()
    if area_clicked(186,499,228,550)
      repeat_song()
    end
  end


  # Unmute Click Event When Volume is muted/0
  def mute()
    if @track_playing
      if @volume == 0.0
        if area_clicked(750,480,785,520)
          @volume = 0.5
          @music.volume = @volume
        end
      end
    end
  end


  #EXTERNAL PLAYER EVENT CLICK
  def external_player_click()
    if @track_playing == true && area_clicked(566,488,620,550)
      @music.stop
      #opens a system call to external vlc media player
      vlc = VLC::System.new
      #multiple songs can be added to playlist 
      vlc.add_to_playlist(@current_track_location) 
      vlc.play
    end
  end


  #all player controls clustered into one function for ease of use
  def player_controls_click()
    play_pause_click()
    repeat_click()
    volume_click()
    add_to_favorites()
    forward_backward_click()
    external_player_click()
    mute()
  end


  #handles the clicking on tracks
  def track_click_event()
    xL = 230
    xR = 600
    yT = 100
    yB = 120
    i = 0
    while (i < @current_album_track_count)
      if area_clicked(xL, yT, xR, yB)
        @current_track = i
        if @current_album != "favorites"
          play_track(@current_track, @albums[@current_album])
          break
        else
          play_track(@current_track, @favorites_list)
          break
        end
      elsif
        yT += 35
        yB += 30
      end
      i += 1
    end
  end


  #handles all player scene click events
  def player_scene_click_events()  
    if area_clicked(50, 50, 100, 100)
      @scene = :menu1
    end
  
    #PLAYER CONTROLS CLICK EVENT
    player_controls_click()

    #TRACK PLAYING
    track_click_event()

  end

                                                #########################
                                                ## KEYBOARD BUTTONDOWN ##
                                                #########################

  #Play/Pause using the space bar
  def keyboard_play_pause()
    if @track_playing == nil && @scene != :genre_sort
      @track_playing = true
      @current_track = 0
      play_track(@current_track, @albums[@current_album])
    elsif @track_playing
      @music.pause
      @track_playing = false
    elsif !@track_playing
      @music.play
      @track_playing = true
    end
  end


  #mute volume using keyboard 'M'
  def keyboard_mute()
    if @music != nil
      if @volume != 0
        @volume = 0
        @music.volume = @volume
      else 
        @volume = 0.5
        @music.volume = @volume
      end
    end
  end


  #HANDLES ALL BUTTON DOWN EVENTS
	def button_down(id)
		case id
      #ALBUM CLICK EVENT
	    when Gosu::MsLeft

      #close application 
      close_application()

      #click events for for menu1 scene
      if @scene == :menu1
        favorites_album_click()
        menu_paging_click()
        genre_sort_click()
        count = 0
        while (count <= 2)
          if area_clicked(@albums_position[count][0],@albums_position[count][1],@albums_position[count][2],@albums_position[count][3])
            @current_album = count
            @scene = :player
            print(@albums[@current_album])
            break
          else
            count += 1
          end
        end

      #click events for menu2 scene
      elsif @scene == :menu2
        favorites_album_click()
        menu_paging_click()
        genre_sort_click()
        count = 3
        if (@albums.length > 5)
          while (2 < count && count <= 5)
            if area_clicked(@albums_position[count][0],@albums_position[count][1],@albums_position[count][2],@albums_position[count][3])
              @current_album = count
              @scene = :player
              print(@albums[@current_album])
              break
            else
              count += 1
            end
          end
        end

      #click event for menu3 scene
      elsif @scene == :menu3
        favorites_album_click()
        menu_paging_click()
        genre_sort_click()
        count = 6
        if (@albums.length > 5)
          while (5 < count && count < @albums.length)
            if area_clicked(@albums_position[count][0],@albums_position[count][1],@albums_position[count][2],@albums_position[count][3])
              @current_album = count
              @scene = :player
              print(@albums[@current_album])
              break
            else
              count += 1
            end
          end
        end

      #player scene click events
      elsif @scene == :player
        if @current_album != "favorites"
          @current_album_track_count = @albums[@current_album].tracks.length 
        else
          @current_album_track_count = @favorites_list.length
        end
        player_scene_click_events() 

      #click events for genre sortes menu
      elsif @scene == :genre_sort
        select_genre()
        select_track_by_genre()
        if area_clicked(50, 50, 100, 100)
          @scene = :menu1
        end
      end

    #decrease volume with down_arrow  
    when Gosu::KbDown 
      if(@volume > 0)
        @volume -= 0.25
      else
        @volume = 0
      end
      if @track_playing
        @music.volume = @volume
      end

    # Increase volume with up arrow
    when Gosu::KbUp
      if (@volume < 1)
        @volume += 0.25
      else
        @volume = 1
      end
      if @track_playing
        @music.volume = @volume
      end

    #play/pause song with spacebar
    when Gosu::KbSpace
      if(@scene == :player || @scene == :genre_sort)
        keyboard_play_pause()
      end

    #mute volume with keyboard key 'M'
    when Gosu::KbM
      if(@scene == :player)
        keyboard_mute()
      end

    #toggle repeat on a song with 'R' key
    when Gosu::KbR
      if(@scene == :player)
        repeat_song()
      end

    #close application with a 'Q' press
    when Gosu::KbQ
      close()
	  end
  end

                                            #########################
                                            ## TRACK PLAY FUNCTION ##
                                            #########################

  # play track mechanism
  def play_track(track, album)
    @track_playing = true

    # Track Playing Mechanism in Album
    if @current_album != "favorites"
      @playing_track_name = album.tracks[track].name
      @playing_artist = album.artist
      @current_track_location = (album.tracks[track].location.chomp)
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
  
    # Track Playing Mechanism in Favorites Album
    elsif @current_album == "favorites"
      @playing_track_name = album[track].name
      @playing_artist = album[track].artist
      @current_track_location = album[track].location.chomp
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
    end
  end
  
  # playing tracks from genre sort menu
  def play_track_by_genre(current_track)
    @track_playing = true
    @playing_track_name = @genre_tracklist[current_track].name
    @current_track_location = @genre_tracklist[current_track].location.chomp
    print("PLAYING #{@playing_track_name}")
    @music = Gosu::Song.new(@current_track_location)
    @music.play(@current_track_repeat)
  end
end

                                                  ###################
                                                  ## OPTION PARSER ##
                                                  ###################

# Uses OptionParser to Take a commandline option
options = {}
OptionParser.new do |parser|
  options[:gui] = false
  #for the gui mode
  parser.on("-g", "--gui", "GUI MODE MUSIC PLAYER") do
    options[:gui] = true
  end
  options[:cli] = false
  #for the cli mode
  parser.on("-c", "--cli", "CLI MODE") do
    options[:cli] = true
  end
  #for help on the options
  parser.on("-h","--help", "Help Menu") do 
    options[:help] = true
  end
end.parse!
if options[:gui] #open gui
  MusicPlayerMain.new.show if __FILE__ == $0
elsif options[:cli] #open cli
  main_menu_albums()
elsif options[:help]  #display help text 
  puts("AUTHOR:\nEkrar Uddin Mohammed Efaz\n\nPROGRAM:\nMUSIC PLAYER\n\nUSAGE:\nruby [filename] --gui\nGUI MODE : --gui/-g\nCLI MODE: --cli,-c".red)
else
  puts("USAGE\n   ruby [filename] --gui\nGUI MODE:\n   --gui/-g\nCLI MODE:\n   --cli,-c\n".red)
end
