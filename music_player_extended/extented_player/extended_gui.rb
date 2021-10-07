require 'rubygems'
require 'gosu'
require 'optparse'
require 'tk'
# require_relative
require_relative 'input_functions'
require_relative 'album_functions'

#Works on Linux with vlc installed 
#For Mac an alias must set to vlc system call via terminal
#Following commands for OSX:
#echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#echo "alias cvlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#Windows not supported
require "vlc-client"

TOP_COLOR = Gosu::Color.new(0xFF858177)
BOTTOM_COLOR = Gosu::Color.new(0xFF858177)
UI_COLOR = Gosu::Color.new(0xFFffffff)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, JAZZ, ROCK, METAL = *1..4
end


GENRE_NAMES = ['Null', 'Pop', 'Jazz', 'Rock', 'Metal']

class ArtWork
	attr_accessor :bmp
	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

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

class Track
  attr_accessor :name, :location
  def initialize(name, location)
      @location = location
      @name = name 
  end
end

class Favorites 
  attr_accessor :name, :artist, :location
  def initialize(name, location, artist)
    @name = name
    @location = location 
    @artist = artist
  end
end

class MusicPlayerMain < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
	def initialize
	  super WIDTH, HEIGHT
	  self.caption = "Music Player"
    @scene = :menu1
    @album_count = nil
    #reading album file with ruby tk
    root = TkRoot.new
    root.title = "window"
    @filename = Tk::getOpenFile
    puts(@filename).class
    music_file = open(@filename,"r")
    @albums = read_albums(music_file) 
    print(@albums)
    
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
    @favorites_list = []
    #array holding all the album positions
    @albums_position = [@album1_position,@album2_position,@album3_position,@album4_position,@album5_position,@album6_position,@album7_position]
    @track_playing = nil
    @current_album = nil
    @current_album_track_count = nil
    @current_track_repeat = false
    @current_track_location = nil
    @current_track = nil
    @music = nil
    @volume = 1
	end

                                                    #####################
                                                    ## 1 ALBUM READING ##
                                                    #####################

  #read a single track

  def read_track(music_file)
    name = music_file.gets()
    location = music_file.gets()
    return Track.new(name,location)
  end

  #store all tracks in array

  def read_tracks(music_file)
    i = 0
    tracks = Array.new()
    @album_count = music_file.gets().to_i()
    while (i < @album_count)
      track = read_track(music_file)
      tracks << track
      i = i+1
    end
    return tracks
  end

  #read a single album information

  def read_album(music_file)
    i = 0
    album_id = i + 1
    album_artist = music_file.gets()
    album_title = music_file.gets()
    album_artwork = music_file.gets()
    album_genre = music_file.gets().to_i()
    tracks = read_tracks(music_file)
    album = Album.new(album_id, album_title,album_artist,album_artwork, album_genre,tracks)
    return album
  end

  #store all albums in array

  def read_albums music_file
    count = music_file.gets().to_i()
    albums = Array.new
      while (0 < count)
        album = read_album(music_file)
        albums << album
        count -= 1
      end
    return albums
  end

  #determine which area was clicked
  def area_clicked(leftX, topY, rightX, bottomY)
     return (mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY)
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

  def draw_genre_box()
    Gosu.draw_rect(50, 410, 700, 115, Gosu::Color::BLACK, ZOrder::UI,:default)
    Gosu::Font.new(40).draw("Genre Sort",300,450,ZOrder::UI)
  end

  def genre_sort_menu()
    Gosu.draw_rect(150,50,200,200,Gosu::Color::BLACK, ZOrder::UI, :default)
    Gosu::Font.new(40).draw("POP",200,100,ZOrder::UI)
    Gosu.draw_rect(450,50,200,200,Gosu::Color::BLACK, ZOrder::UI, :default)
    Gosu::Font.new(40).draw("JAZZ",500,100,ZOrder::UI)
    Gosu.draw_rect(150,300,200,200,Gosu::Color::BLACK, ZOrder::UI, :default)
    Gosu::Font.new(40).draw("ROCK",200,350,ZOrder::UI)
    Gosu.draw_rect(450,300,200,200,Gosu::Color::BLACK, ZOrder::UI, :default)
    Gosu::Font.new(40).draw("METAL",500,350,ZOrder::UI)
    # Gosu.draw_rect(50,50,100,100,Gosu::Color::BLACK, ZOrder::UI, :default)
    # Gosu.draw_rect(50,50,100,100,Gosu::Color::BLACK, ZOrder::UI, :default)
  end

  def draw_page_button()
    if @scene == :menu1 || :menu2 || :menu3
      # Gosu.draw_rect(760, 50, 50, 200, Gosu::Color::BLACK, ZOrder::UI,:default)
      Gosu::Font.new(50).draw("<",5,125,ZOrder::UI)
      Gosu::Font.new(50).draw(">",770,125,ZOrder::UI)
    end
  end

  #draw the volume rocker button at different volume
  def draw_volume_rocker()
    Gosu.draw_rect(635, 150, 50, 300, Gosu::Color::BLACK, ZOrder::UI,:default)
    if @volume == 1.0
      Gosu.draw_rect(645, 160, 30, 280, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.25
      Gosu.draw_rect(645, 380, 30, 60, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.5
      Gosu.draw_rect(645, 310, 30, 130, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.75
      Gosu.draw_rect(645, 240, 30, 200, UI_COLOR, ZOrder::UI,:default)
    elsif @volume == 0.0
      Gosu.draw_rect(645, 160, 30, 0, UI_COLOR, ZOrder::UI,:default)
    end
  end

  #draw the button to open vlc external player
  def external_player_button()
    Gosu.draw_rect(100, 380, 150, 60, Gosu::Color::BLACK, ZOrder::UI,:default)
    Gosu::Font.new(20).draw("Open in VLC", 120,400, ZOrder::UI)
  end

  #draw the back/return to main menu button
  def draw_back_button()
    Gosu::Font.new(20).draw("< BACK", 50, 50, ZOrder::UI)
  end

  def draw_buttons()
    Gosu.draw_rect(100, 450, 600, 100, UI_COLOR,ZOrder::PLAYER, :default)

    #Forward and backward button
    @forward = Gosu::Image.new('./media/forward.png')
    @forward.draw(500, 480, ZOrder::UI, 0.04,0.04)
    @forward.draw_rot(450,480,ZOrder::UI, 180, 1, 1, scale_x = 0.04, scale_y = 0.04)

    #Toggle-able Play/Pause Button
    if @track_playing == nil
      @play = Gosu::Image.new('./media/play.png')
      @play.draw(350, 460, ZOrder::UI, 0.05,0.05)
    elsif @track_playing
      @pause = Gosu::Image.new('./media/pause.png')
      @pause.draw(350, 475, ZOrder::UI, 0.1,0.1)
    elsif !@track_playing
      @play = Gosu::Image.new('./media/play.png')
      @play.draw(350, 460, ZOrder::UI, 0.05,0.05)
    end

    #Toggle-able Repeat Button
    if @current_track_repeat
      @repeat_active = Gosu::Image.new('./media/repeat1.png')
      @repeat_active.draw(270, 475, ZOrder::UI, 0.07, 0.07)
    else
      @repeat_inactive = Gosu::Image.new('./media/repeat_inactive.png')
      @repeat_inactive.draw(270, 475, ZOrder::UI, 0.2, 0.2)
    end
    @favorite = Gosu::Image.new('./media/favorite_inactive.png')
    @favorite.draw(180,475,ZOrder::UI, 0.2,0.2)
  end

  #display tracks for selected album
  def display_tracks()
    track_y_position = 100
    for track in @albums[@current_album].tracks
      Gosu::Font.new(20).draw(track.name, 400, track_y_position, ZOrder::UI)
      track_y_position += 35
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
      message = "Playing #{@playing_track_name} by #{@playing_artist}"
      Gosu::Font.new(30).draw(message, 300, 350, ZOrder::UI)
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
    puts("RAM NO TRAM")
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

  def draw_menu(albums)
    draw_albums(albums)
  end

  #DRAW FOR ALL SCENES
	def draw
    case @scene
      #draw actions for :menu scene
      when :menu1
        draw_background() 
        draw_menu(@albums)
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
        draw_favorites_box()
        draw_genre_box()
        draw_page_button()
      when :menu2
        draw_background() 
        draw_menu(@albums)
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
        draw_favorites_box()
        draw_genre_box()
        draw_page_button()
      when :menu3
        draw_background() 
        draw_menu(@albums)
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
        draw_favorites_box()
        draw_genre_box()
        draw_page_button()
      when :genre_sort
        draw_background() 
        draw_back_button()
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
        genre_sort_menu()
      #draw actions for :player scene
      when :player
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
        external_player_button()
        display_playing_track()
        draw_buttons()
        draw_volume_rocker()
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
      end
	end

  #to show the cursor in program
 	def needs_cursor?; true; end

                                      ###################################
                                      ## CLICK EVENT HANDLER FUNCTIONS ##
                                      ###################################

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

  def play_pause_click()
    #PLAY PAUSE BUTTON EVENT
    if @track_playing == nil && area_clicked(365,368,414,521)
      track_playing = true
      @current_track = 0
      playTrack(@current_track, @albums[@current_album])
    elsif @track_playing && area_clicked(350,405,475,525)
      @music.pause
      @track_playing = false
    elsif !@track_playing && area_clicked(365,368,414,521) 
      @music.play
      @track_playing = true
    end
  end

  def forward_backward_click()
    #BACKWARD BUTTON
    if (@track_playing && @current_track > 0 && area_clicked(454,483,482,520))
      @current_track -= 1 #backward
      playTrack(@current_track, @albums[@current_album])
    
    #FORWARD BUTTON
    elsif (@track_playing && @current_track < @current_album_track_count && area_clicked(500,482,531,525))
      @current_track += 1  #forward
      playTrack(@current_track, @albums[@current_album])
    end
  end
  
  def volume_click()
    #VOLUME BUTTON EVENT
    if @track_playing && area_clicked(645,380,675,450)
      @music.volume = 0.25
      @volume = @music.volume
    elsif @track_playing && area_clicked(645,290,675,380)
      @music.volume = 0.5
      @volume = @music.volume
    elsif @track_playing && area_clicked(645,240,675,290)
      @music.volume = 0.75
      @volume = @music.volume
    elsif @track_playing && area_clicked(645,150,675,240)
      @music.volume = 1.0
      @volume = @music.volume
    end
  end

  def add_to_favorites()
    #ADDING, REMOVING TO FAVORITES ALBUM
    if (@track_playing && area_clicked(181,475,221,517))
      favorite_track = Favorites.new(@albums[@current_album].tracks[@current_track].name, @albums[@current_album].tracks[@current_track].location, @albums[@current_album].artist)
      if @favorites_list.include? favorite_track
        @favorites_list.delete favorite_track
        puts("deleted")
      else
        @favorites_list << favorite_track
        puts(favorite_track)
      end
    end
  end

  def repeat_click()
    #REPEAT BUTTON EVENT
    if @current_track_repeat && area_clicked(277,478,310,519)
      @current_track_repeat = false
    elsif !@current_track_repeat && area_clicked(277,478,310,519)
      @current_track_repeat = true
    end
  end

  def external_player_click()
    #EXTERNAL PLAYER EVENT CLICK
    if @track_playing == true && area_clicked(100,380,250,440)
      @music.stop
      #opens a system call to external vlc media player
      vlc = VLC::System.new
      #multiple songs can be added to playlist 
      vlc.add_to_playlist(@current_track_location) 
      vlc.play
    end 
  end

  def player_controls_click()
    play_pause_click()
    repeat_click()
    volume_click()
    add_to_favorites()
    external_player_click()
  end

  def player_scene_click_events()
    #BACK BUTTON CLICK   
    if area_clicked(50, 50, 100, 100)
      @scene = :menu1
    end
  
    #PLAYER CONTROLS CLICK EVENT
    player_controls_click()

    #ALBUM TRACK COUNTING
    xL = 230
    xR = 600
    yT = 100
    yB = 120
    i = 0

    #TRACK PLAYING
    while (i < @current_album_track_count)
      if area_clicked(xL, yT, xR, yB)
        @current_track = i
        if @current_album != "favorites"
          playTrack(@current_track, @albums[@current_album])
          break
        else
          playTrack(@current_track, @favorites_list)
          break
        end
      elsif
        yT += 35
        yB += 30
      end
      i += 1
    end
  end

  #HANDLES ALL BUTTON DOWN EVENTS
	def button_down(id)
		case id
	    when Gosu::MsLeft
      #ALBUM CLICK EVENT
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
      elsif @scene == :menu2
        favorites_album_click()
        menu_paging_click()
        genre_sort_click()
        count = 3
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
      elsif @scene == :menu3
        favorites_album_click()
        menu_paging_click()
        genre_sort_click()
        count = 6
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
      elsif @scene == :player
        if @current_album != "favorites"
          @current_album_track_count = @albums[@current_album].tracks.length 
        else
          @current_album_track_count = @favorites_list.length
        end
        player_scene_click_events() 
      elsif @scene == :genre_sort
        if area_clicked(50, 50, 100, 100)
          @scene = :menu1
        end
      end        
	  end
  end
  
                                                #########################
                                                ## TRACK PLAY FUNCTION ##
                                                #########################

  def playTrack(track, album)
    @track_playing = true
    if @current_album != "favorites"
      @playing_track_name = album.tracks[track].name
      @playing_artist = album.artist
      print("PLAYING #{album.tracks[track].name}")
      @current_track_location = (album.tracks[track].location.chomp)
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
      puts (album.tracks[track].location)
    elsif @current_album == "favorites"
      @playing_track_name = album[track].name
      @playing_artist = album[track].artist
      @current_track_location = album[track].location.chomp
      print("PLAYING #{album[track].name}")
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
    end
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
if options[:gui]
  MusicPlayerMain.new.show if __FILE__ == $0
elsif options[:cli]
  main_menu_albums()
elsif options[:help]
  puts("USAGE: ruby [filename] --gui\nGUI MODE : --gui/-g\nCLI MODE: --cli,-c")
end