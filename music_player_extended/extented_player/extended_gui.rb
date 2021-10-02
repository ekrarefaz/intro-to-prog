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
BOTTOM_COLOR = Gosu::Color.new(0x858177)
UI_COLOR = Gosu::Color.new(0xFFffffff)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK, METAL = *1..5
end


GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock', 'Metal']

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
  attr_accessor :name, :location, :favorite
  def initialize(name, location)
      @location = location
      @name = name 
      @favorite = false
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
    x = 20
    y = 50
    @scene = :menu
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
    @favorites_position = [x, y + 200, 206, 435]
    @album1_position = [x, y, 183 , 220]
    @album2_position = [x + 200, y, 377, 220]
    @album3_position = [x + 400, y, 579, 220]
    @album4_position = [x + 600, y, 782, 220]
    @album5_position = [x + 200, y + 200, 396, 435]
    @album6_position = [x + 400, y + 200, 595, 435]
    @album7_position = [x + 600, y + 200, 790, 435]
    #array holding all the album positions
    @albums_position = [@album1_position,@album2_position,@album3_position,@album4_position,@album5_position,@album6_position,@album7_position]
    #instance variables for :player scene
    @current_album = nil
    @current_album_track_count = nil
    @current_track = nil
    @current_track_repeat = false
    @current_track_location = nil
    @music = nil
    @track_playing = nil
    @favorites_list = Array.new()
    @volume = 1.0
	end
  # 1 ALBUM READING
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
  #draw the background
	def draw_background
    Gosu.draw_rect(0,0,WIDTH,HEIGHT,TOP_COLOR,ZOrder::BACKGROUND,:default)
  end
  #nothing in the update function all events handled by mouse clicked
	def update
	end
  #DRAW FOR ALL SCENES
	def draw
    case @scene
      #draw actions for :menu scene
      when :menu
        draw_background() 
        draw_menu(@albums) 
        draw_genre_button() 
        # Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        # Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
      #draw actions for :player scene
      when :player
        draw_background()
        #check if the selected album is favorites album
        if @current_album != 8
          draw_album(@albums[@current_album])
          draw_back_button()
          display_tracks()
        else
          draw_back_button()
          display_favorite_tracks()
        end
        external_player_button()
        display_playing_track()
        draw_buttons()
        draw_volume_rocker()
        Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
        Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
      #draw actions for sort by genre scene
      when :gsort
        draw_background()
        display_genre()
    end
	end
  #display genre title
  def display_genre()
    i = 1
    x = 20
    while (i < 6)
    Gosu::Font.new(30).draw(GENRE_NAMES[i],x,50,ZOrder::UI)
    x += 150
    i += 1
    end
    Gosu::Font.new(30).draw(mouse_x,700,300,ZOrder::UI)
    Gosu::Font.new(30).draw(mouse_y,700,400,ZOrder::UI)
    draw_by_genre()
  end
  #draw albums in specific genre section
  def draw_by_genre()
    pop = 0
    jazz = 0
    classic = 0
    metal = 0
    rock = 0
    i = 0
    x = 25
    a = 100
    b = 100
    c = 100
    d = 100 
    e = 100
    for album in @albums
      if album.genre == 1
        album_artwork = Gosu::Image.new(album.artwork.chomp)
        album_artwork.draw(x, a, ZOrder::UI, 0.45, 0.45)
        a += 110
      elsif album.genre == 2
        album_artwork = Gosu::Image.new(album.artwork.chomp)
        album_artwork.draw(x + 150, b, ZOrder::UI, 0.45, 0.45)
        classic += 1
        b += 110
      elsif album.genre == 3
        album_artwork = Gosu::Image.new(album.artwork.chomp)
        album_artwork.draw(x + 300, c, ZOrder::UI, 0.4, 0.4)
        jazz += 1
        c += 110
      elsif album.genre == 4
        album_artwork = Gosu::Image.new(album.artwork.chomp)
        album_artwork.draw(x + 450, d, ZOrder::UI, 0.35, 0.35)
        rock += 1
        d += 130
      elsif album.genre == 5
        album_artwork = Gosu::Image.new(album.artwork.chomp)
        album_artwork.draw(x + 600, e, ZOrder::UI, 0.3, 0.3)
        metal += 1
        e += 110
      end
    end
  end
  #to show or not to show the cursor in program
 	def needs_cursor?; true; end
  #HANDLES ALL BUTTON DOWN EVENTS
	def button_down(id)
		case id
	    when Gosu::MsLeft

        #ALBUM CLICK EVENT
        if @scene == :menu && area_clicked(@album1_position[0], @album1_position[1], @album1_position[2], @album1_position[3])
          @current_album = 0
          @scene = :player
          print(@albums[@current_album])
        end
        if @scene == :menu && area_clicked(@album2_position[0], @album2_position[1], @album2_position[2], @album2_position[3])
          @current_album = 1
          @scene = :player
          print(@albums[@current_album])
        end
        if @scene == :menu && area_clicked(@album3_position[0], @album3_position[1], @album3_position[2], @album3_position[3])
          @scene = :player
          @current_album = 2
        end
        if @scene == :menu && area_clicked(@album4_position[0], @album4_position[1], @album4_position[2], @album4_position[3])
          @scene = :player
          @current_album = 3
        end
        if @scene == :menu && area_clicked(@album5_position[0], @album5_position[1], @album5_position[2], @album5_position[3])
          @current_album = 4
          @scene = :player
          print(@albums[@current_album])
        end
        if @scene == :menu && area_clicked(@album6_position[0], @album6_position[1], @album6_position[2], @album6_position[3])
          @current_album = 5
          @scene = :player
          print(@albums[@current_album])
        end
        if @scene == :menu && area_clicked(@album7_position[0], @album7_position[1], @album7_position[2], @album7_position[3])
          @current_album = 6
          @scene = :player
          print(@albums[@current_album])
        end

        #GENRE SORT SCENE CLICK EVENTS
        if @scene == :gsort
          if area_clicked(25,100,115,190)
            @current_album = 0
            @scene = :player
          elsif area_clicked(175,100,265,190)
            @current_album = 2
            @scene = :player
          elsif area_clicked(325,100,415,190)
            @current_album = 1
            @scene = :player
          elsif area_clicked(475,100,555,190)
            @current_album = 3
            @scene = :player
          elsif area_clicked(475,230,555,340)
            @current_album = 4
            @scene = :player
          elsif area_clicked(475,360,555,465)
            @current_album = 6
            @scene = :player
          elsif area_clicked(625,100,720,190)
            @current_album = 5
            @scene = :player
          end
        end

        #FAVORITES ALBUM CLICK EVENT
        if @scene == :menu && area_clicked(@favorites_position[0],@favorites_position[1],@favorites_position[2],@favorites_position[3])
          @scene = :player
          @current_album = 8
        end

        #GENRE SORTING EVENT
        if @scene == :menu && area_clicked(20, 525, 180, 580)
          @scene = :gsort
        end

        #EXTERNAL PLAYER EVENT CLICK
        if @track_playing == true && area_clicked(100,380,250,440)
          @music.pause
          #Works on Linux with vlc installed 
          #For Mac an alias must set to vlc system call via terminal
          #Following commands for OSX:
          #echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
          #echo "alias cvlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
          #Windows not supported
          vlc = VLC::System.new #opens a system call to external vlc media player
          vlc.add_to_playlist(@current_track_location) #multiple songs can be added to playlist
          vlc.play
        end
                    
        #ALBUM TRACK COUNTING
        if @current_album != 8
          @current_album_track_count = @albums[@current_album].tracks.length 
        else
          @current_album_track_count = @favorites_list.length
        end

        #PLAYER TRACK SELECT , PLAY 
        if @scene == :player
          if area_clicked(50, 50, 100, 100)
            @scene = :menu
          end

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

          #BACKWARD BUTTON
          if (@track_playing && @current_track > 0 && area_clicked(454,483,482,520))
            @current_track -= 1 #backward
            playTrack(@current_track, @albums[@current_album])

          #FORWARD BUTTON
          elsif (@track_playing && @current_track < @current_album_track_count && area_clicked(500,482,531,525))
            @current_track += 1  #forward
            playTrack(@current_track, @albums[@current_album])
          end

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

          #REPEAT BUTTON EVENT
          if @current_track_repeat && area_clicked(277,478,310,519)
            @current_track_repeat = false
          elsif !@current_track_repeat && area_clicked(277,478,310,519)
            @current_track_repeat = true
          end

          #ADDING, REMOVING TO FAVORITES ALBUM
          if (@track_playing && area_clicked(181,475,221,517))
            @albums[@current_album].tracks[@current_track].favorite = true
            favorite_track = Favorites.new(@albums[@current_album].tracks[@current_track].name, @albums[@current_album].tracks[@current_track].location, @albums[@current_album].artist)
            if @favorites_list.include? favorite_track
              @favorites_list.delete favorite_track
              puts("deleted")
            else
              @favorites_list << favorite_track
            end
            puts @favorites_list
          end

          xL = 230
          xR = 600
          yT = 100
          yB = 120
          i = 0
          #TRACK PLAYING
            while (i < @current_album_track_count)
              if area_clicked(xL, yT, xR, yB)
                @current_track = i
                if @current_album != 8
                  playTrack(@current_track, @albums[@current_album])
                  break
                else
                  playTrack(@current_track, @favorites_list)
                  break
                end
              elsif
                yT += 25
                yB += 20
              end
              i += 1
            end
          end
	      end
	end
  #display tracks for selected album
  def display_tracks()
    track_y_position = 100
    for track in @albums[@current_album].tracks
      Gosu::Font.new(20).draw(track.name, 400, track_y_position, ZOrder::UI)
      track_y_position += 20
    end
  end

  #draw the favorite albums tracks
  def display_favorite_tracks()
    Gosu::Image.new('./media/fav.jpg').draw(20, 100, ZOrder::UI, 0.2, 0.2)
    track_y_position = 100
    i = 0
    while ( i < @favorites_list.length)
      Gosu::Font.new(20).draw(@favorites_list[i].name, 400, track_y_position, ZOrder::UI)
      track_y_position += 20
      i += 1
    end
  end

  #play tracks
  def playTrack(track, album)
    @track_playing = true
    if @current_album != 8
      @playing_track_name = album.tracks[track].name
      @playing_artist = album.artist
      print("PLAYING #{album.tracks[track].name}")
      @current_track_location = (album.tracks[track].location.chomp)
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
      puts (album.tracks[track].location)
    elsif @current_album == 8
      @playing_track_name = album[track].name
      @playing_artist = album[track].artist
      @current_track_location = album[track].location.chomp
      print("PLAYING #{album[track].name}")
      @music = Gosu::Song.new(@current_track_location)
      @music.play(@current_track_repeat)
    end
  end

  #text display the playing track
  def display_playing_track
    if @track_playing
      message = "Playing #{@playing_track_name} by #{@playing_artist}"
      Gosu::Font.new(30).draw(message, 300, 350, ZOrder::UI)
    end
  end

  #draw all the albums in the :menu page
  def draw_albums(albums)
    i = 0
    while (i < @albums.length)
      album_artwork = Gosu::Image.new(albums[i].artwork.chomp)
      album_artwork.draw(@albums_position[i][0],@albums_position[i][1],ZOrder::UI, 0.56,0.56)
      i += 1
    end
    favorites_artwork = Gosu::Image.new('./media/fav.jpg')
    favorites_artwork.draw(@favorites_position[0],@favorites_position[1], ZOrder::UI, 0.18, 0.18)
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

  #draw  the sort by genre button
  def draw_genre_button()
    Gosu.draw_rect(25, 525, 160, 55, Gosu::Color::BLACK, ZOrder::UI,:default)
    Gosu::Font.new(20).draw("Genre Sort", 35, 540, ZOrder::UI)
  end
  
  #Draws the current album selected in :player mode
  def draw_album(album)
    x = 20
    y = 100
    if @current_album != 8
      current_album_artwork = Gosu::Image.new(@albums[@current_album].artwork.chomp)
      current_album_artwork.draw(x, y, ZOrder::UI,1,1)
    end
    display_tracks()
  end

  #Procedure Draws all the media controls
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

  def draw_menu(albums)
    draw_albums(albums)
  end
end

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