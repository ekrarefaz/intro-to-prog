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

    @current_album = 0
    @current_album_track_count = 3
    @current_track = nil
    @current_track_repeat = false
    @current_track_location = nil
    @music = nil
    @action = nil
    @track_playing = nil
    @album1_position = [20, 50, 200 , 300]

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
     return (mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY)
  end

	def draw_background
    Gosu.draw_rect(0,0,WIDTH,HEIGHT,TOP_COLOR,ZOrder::BACKGROUND,:default)
  end

	def update

	end

	def draw
    draw_background
    draw_albums(@albums)
    # Gosu::Font.new(30).draw(mouse_x,700,100,ZOrder::UI)
    # Gosu::Font.new(30).draw(mouse_y,700,200,ZOrder::UI)
    if (@action == :show_tracks)
      display_tracks
      display_playing_track
    end
	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
        xL = 230
        xR = 600
        yT = 100
        yB = 120
        i = 0
        if area_clicked(20,50,200,300)
          @action = :show_tracks
        end
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

  def display_tracks()
    track_y_position = 100
    for track in @albums[@current_album].tracks
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
    album_1_artwork.draw(@album1_position[0], @album1_position[1], ZOrder::UI,1,1)
  end

end

MusicPlayerMain.new.show if __FILE__ == $0