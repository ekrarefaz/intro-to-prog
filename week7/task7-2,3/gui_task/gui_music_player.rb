require 'rubygems'
require 'gosu'
require 'plllayer'
require_relative 'input_functions'

TOP_COLOR = Gosu::Color.new(0xFF858177)
BOTTOM_COLOR = Gosu::Color.new(0x858177)
UI_COLOR = Gosu::Color.new(0xFFffffff)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

$album_file_name = "album.txt"
GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

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

class MusicPlayerMain < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
	def initialize
	  super WIDTH, HEIGHT
	  self.caption = "Music Player"
    x = 20
    y = 50
    @current_album = nil
    @current_album_track_count = nil
    @current_track = nil
    @current_track_repeat = false
    @current_track_location = nil
    @scene = :menu
    @music = nil
    @track_playing = nil
    @favorite_tracks = []
    @album1_position = [x, y, 200 , 300]
    @album2_position = [x + 200, y, 400, 400]
    @album3_position = [x + 400, y, 600, 400]
    @album4_position = [x + 600, y, 800, 400]

    music_file = open('album.txt',"r")
    @albums = read_albums(music_file) 
    print(@albums)
	end

  # 1 ALBUM READING
  def read_track(music_file)
    name = music_file.gets()
    location = music_file.gets()
    return Track.new(name,location)
  end

  def read_tracks(music_file)
    i = 0
    tracks = Array.new()
    count = music_file.gets().to_i()
    while (i < count)
        track = read_track(music_file)
        tracks << track
        i = i+1
    end
    return tracks
  end

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

  def area_clicked(leftX, topY, rightX, bottomY)
     # complete this code
     return (mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY)
  end

	def draw_background
    Gosu.draw_rect(0,0,WIDTH,HEIGHT,TOP_COLOR,ZOrder::BACKGROUND,:default)
  end

	def update

	end

	def draw
    case @scene
    when :menu
      draw_background
      draw_menu(@albums)
      Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
      Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
    when :player
      draw_background
      if @current_album != 4
        draw_album(@albums[@current_album])
        display_tracks
      else
        display_favorite_tracks
      end
      display_playing_track
      draw_buttons
      Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
      Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
    end
	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
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

        #FAVORITES ALBUM CLICK EVENT
        if @scene == :menu && area_clicked(20, 260, 213, 388)
          @scene = :player
          @current_album = 4
        end
        #ALBUM TRACK COUNTING
        if @current_album != 4
          @current_album_track_count = @albums[@current_album].tracks.length 
        else
          @current_album_track_count = @favorite_tracks.length
        end
        #PLAYER TRACK SELECT , PLAY 
        if @scene == :player
          if area_clicked(50, 50, 100, 100)
            @scene = :menu
          end
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

          #REPEAT BUTTON EVENT
          if @current_track_repeat && area_clicked(277,478,310,519)
            @current_track_repeat = false
          elsif !@current_track_repeat && area_clicked(277,478,310,519)
            @current_track_repeat = true
          end
          #ADDING, REMOVING TO FAVORITES ARRAY
          if (@track_playing && area_clicked(181,475,221,517))
            @albums[@current_album].tracks[@current_track].favorite = true
            if @favorite_tracks.include? @albums[@current_album].tracks[@current_track]
              @favorite_tracks.delete @albums[@current_album].tracks[@current_track]
              puts("deleted")
              puts @favorite_tracks
            else
              @favorite_tracks << @albums[@current_album].tracks[@current_track]
              puts(@favorite_tracks)
            end
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
                playTrack(@current_track, @albums[@current_album])
                break
              elsif
                yT += 25
                yB += 20
              end
              i += 1
            end
          end
	      end
	end

  def display_tracks()
    track_y_position = 100
    for track in @albums[@current_album].tracks
      Gosu::Font.new(20).draw(track.name, 400, track_y_position, ZOrder::UI)
      track_y_position += 20
    end
  end

  def display_favorite_tracks()
    Gosu::Image.new('./media/fav.jpg').draw(20, 100, ZOrder::UI, 0.5, 0.5)
    track_y_position = 100
    for track in @favorite_tracks
      Gosu::Font.new(20).draw(track.name, 400, track_y_position, ZOrder::UI)
      track_y_position += 20
    end
  end

  def playTrack(track, album)
    @track_playing = true
    @playing_track_name = album.tracks[track].name
    @playing_artist = album.artist
    print("PLAYING #{album.tracks[track].name}")
    @current_track_location = (album.tracks[track].location.chomp)
  	@music = Gosu::Song.new(@current_track_location)
  	@music.play(@current_track_repeat)
    puts (album.tracks[track].location)
  end

  def display_playing_track
    if @track_playing
      message = "Playing #{@playing_track_name} by #{@playing_artist}"
      Gosu::Font.new(30).draw(message, 300, 350, ZOrder::UI)
    end
  end

  def draw_albums(albums)
    album_1_artwork = Gosu::Image.new(albums[0].artwork.chomp)
    album_1_artwork.draw(@album1_position[0], @album1_position[1], ZOrder::UI, 0.7, 0.7)
    
    album_2_artwork = Gosu::Image.new(albums[1].artwork.chomp)
    album_2_artwork.draw(@album2_position[0], @album2_position[1], ZOrder::UI, 0.7, 0.7)
    
    album_3_artwork = Gosu::Image.new(albums[2].artwork.chomp)
    album_3_artwork.draw(@album3_position[0], @album3_position[1], ZOrder::UI, 0.7, 0.7)
    
    album_4_artwork = Gosu::Image.new(albums[3].artwork.chomp)
    album_4_artwork.draw(@album4_position[0], @album4_position[1], ZOrder::UI, 0.7, 0.7)

    favorites_artwork = Gosu::Image.new('./media/fav.jpg')
    favorites_artwork.draw(22, 260, ZOrder::UI, 0.3, 0.3)
  end

  def draw_album(album)
    x = 20
    y = 100
    Gosu::Font.new(20).draw("< BACK", 50, 50, ZOrder::UI)
    if @current_album != 4
      current_album_artwork = Gosu::Image.new(@albums[@current_album].artwork.chomp)
      current_album_artwork.draw(x, y, ZOrder::UI,1.3,1.3)
    end
    display_tracks()
  end

  def draw_buttons
    Gosu.draw_rect(100, 450, 600, 100, UI_COLOR,ZOrder::PLAYER, :default)

    @forward = Gosu::Image.new('./media/forward.png')
    @forward.draw(500, 480, ZOrder::UI, 0.04,0.04)
    @forward.draw_rot(450,480,ZOrder::UI, 180, 1, 1, scale_x = 0.04, scale_y = 0.04)
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

MusicPlayerMain.new.show if __FILE__ == $0