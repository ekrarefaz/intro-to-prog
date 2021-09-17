
require "rubygems"
require "gosu"

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ["Null", "Pop", "Classic", "Jazz", "Rock"]

class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
  end
end

class Album
  # NB: you will need to add tracks to the following and the initialize()
  attr_accessor :title, :artist, :genre, :artwork, :tracks

  # complete the missing code:
  def initialize(title, artist, genre, artwork, tracks)
    # insert lines here
    @title = title
    @artist = artist
    @genre = genre
    @artwork = artwork
    @tracks = tracks
  end
end

class Track
  attr_accessor :name, :location

  def initialize(name, location)
    @name = name
    @location = location
  end
end

# Put your record definitions here

class MusicPlayerMain < Gosu::Window
  def initialize
    super 600, 800
    self.caption = "Music Player"
    @album1_position = [100, 150, 250, 300]
    @album2_position = [300, 150, 450, 300]
    @album3_position = [100, 400, 250, 550]
    @album4_position = [300, 400, 450, 550]
    # Reads in an array of albums from a file and then prints all the albums in the
    # array to the terminal
    album_file = File.new("album.txt", "r")
    if album_file
      @albums = read_albums(album_file)
      album_file.close
    end
    @current_album = 0
    @track_playing
  end

  # Put in your code here to load albums and tracks

  # Draws the artwork on the screen for all the albums

  def draw_albums(albums)
    album_1_artwork = Gosu::Image.new(albums[0].artwork.chomp)
    album_1_artwork.draw(@album1_position[0], @album1_position[1], ZOrder::UI, 0.5, 0.5)
    album_2_artwork = Gosu::Image.new(albums[1].artwork.chomp)
    album_2_artwork.draw(@album2_position[0], @album2_position[1], ZOrder::UI, 0.5, 0.5)
    album_3_artwork = Gosu::Image.new(albums[2].artwork.chomp)
    album_3_artwork.draw(@album3_position[0], @album3_position[1], ZOrder::UI, 0.5, 0.5)
    album_4_artwork = Gosu::Image.new(albums[3].artwork.chomp)
    album_4_artwork.draw(@album4_position[0], @album4_position[1], ZOrder::UI, 0.5, 0.5)
  end

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def area_clicked(leftX, topY, rightX, bottomY)
    return ((mouse_x >= leftX and mouse_x <= rightX) and (mouse_y >= topY and mouse_y <= bottomY))
  end

  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_track(title, ypos)
    @track_font.draw(title, TrackLeftX, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
  end

  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(tracknumber, album)
    # complete the missing code
    @song = Gosu::Song.new(album.tracks[tracknumber].location.chomp)
    @song.play(false)
    # Uncomment the following and indent correctly:
    #	end
    # end
  end

  # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

  def draw_background
    #Draw the background using the colours given
    Gosu.draw_quad(0, 0, TOP_COLOR, 600, 0, TOP_COLOR, 0, 800, BOTTOM_COLOR, 600, 800, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  # Not used? Everything depends on mouse actions.

  def update
  end

  # Draws the album images and the track list for the selected album

  def draw
    # Complete the missing code
    draw_background
    draw_ui()
    draw_albums(@albums)
    display_tracks()
    Gosu::Font.new(20).draw("mouse_x:#{mouse_x} mouse_y:#{mouse_y}", 20, 780, ZOrder::UI)
    if @track_playing
      Gosu::Font.new(20).draw("Now playing: #{@albums[@current_album].tracks[@track_playing].name.chomp} from #{@albums[@current_album].title}", 20, 600, ZOrder::UI)
    end
  end

  def draw_ui()
    play_button = Gosu::Image.new("play.png")
    play_button.draw(50, 50, ZOrder::UI, 0.5, 0.5)
    pause_button = Gosu::Image.new("pause.png")
    pause_button.draw(150, 50, ZOrder::UI, 0.5, 0.5)
    skipforward_button = Gosu::Image.new("skipforward.png")
    skipforward_button.draw(250, 50, ZOrder::UI, 0.5, 0.5)
    skipback_button = Gosu::Image.new("skipback.png")
    skipback_button.draw(350, 50, ZOrder::UI, 0.5, 0.5)
  end

  def display_tracks()
    # Draw the tracks to the Gosu window
    track_y_position = 630
    for track in @albums[@current_album].tracks
      Gosu::Font.new(20).draw(track.name, 230, track_y_position, ZOrder::UI)
      track_y_position += 20
    end
  end

  def needs_cursor?; true; end

  # If the button area (rectangle) has been clicked on change the background color
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.

  def button_down(id)
    case id
    when Gosu::MsLeft
      # What should happen here?
      # When the first album is clicked
      if area_clicked(@album1_position[0], @album1_position[1], @album1_position[2], @album1_position[3])
        @current_album = 0
      end
      if area_clicked(@album2_position[0], @album2_position[1], @album2_position[2], @album2_position[3])
        @current_album = 1
      end
      if area_clicked(@album3_position[0], @album3_position[1], @album3_position[2], @album3_position[3])
        @current_album = 2
      end
      if area_clicked(@album4_position[0], @album4_position[1], @album4_position[2], @album4_position[3])
        @current_album = 3
      end
      #Make tracks clickable
      if area_clicked(230, 630, 414, 640)
        puts("Playing Track 1")
        @track_playing = 0
        playTrack(0, @albums[@current_album])
      end
      if area_clicked(230, 650, 380, 665)
        puts("Playing Track 2")
        @track_playing = 1
        playTrack(1, @albums[@current_album])
      end
      #Play button
      if area_clicked(50, 50, 100, 100)
        puts("Play button clicked!")
        if @song
          @song.play
        end
      end
      if area_clicked(150, 50, 210, 100)
        puts("Pause button clicked!")
        @song.pause
      end
      if area_clicked(250, 50, 300, 100)
        puts("Skip button clicked!")
        if @track_playing and (@track_playing < @albums[@current_album].tracks.length - 1)
          @track_playing += 1
          playTrack(@track_playing, @albums[@current_album])
        end
      end
      if area_clicked(360, 60, 400, 100)
        puts("Reverse button clicked!")
        if @track_playing and (@track_playing > 0)
          @track_playing -= 1
          playTrack(@track_playing, @albums[@current_album])
        end
      end
    end
  end

  def read_albums(music_file)
    count = music_file.gets().to_i #Reads the first line to get the count of albums
    albums = Array.new() #Creates empty array to store albums
    i = 0
    while (i < count)
      album = read_album(music_file) # Read in an individual album and store it in the album variable.
      albums << album #Push album into albums array
      i += 1
    end
    return albums
  end

  def read_album(music_file)
    album_title = music_file.gets()
    album_artist = music_file.gets()
    album_genre = music_file.gets.to_i()
    album_artwork = music_file.gets()
    tracks = read_tracks(music_file)
    album = Album.new(album_title, album_artist, album_genre, album_artwork, tracks)
    return album
  end

  def read_tracks(music_file)
    tracks = Array.new()
    count = music_file.gets().to_i()
    i = 0
    while (i < count)
      # Put a while loop here which increments an index to read the tracks
      track = read_track(music_file)
      tracks << track
      i += 1
    end
    return tracks
    # Put a while loop here which increments an index to read the track
  end

  def read_track(music_file)
    track_title = music_file.gets()
    track_location = music_file.gets()
    track = Track.new(track_title, track_location)
    return track
  end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
