module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end
# global variable to map genre
$genre_names = ["Null", "Pop", "Classic", "Jazz", "Rock"]

class Album 
    attr_accessor :title, :artist, :genre , :tracks
    def initialize(title, artist, genre, tracks)
        @title = title 
        @artist = artist 
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
    album_artist = music_file.gets()
    album_title = music_file.gets()
    album_genre = music_file.gets().to_i()
    tracks = read_tracks(music_file)
    album = Album.new(album_title,album_artist,album_genre,tracks)
    return album
end

def print_tracks(tracks)
  i = 0
  while (i<tracks.length)
    print_track(tracks[i])
    i += 1
  end
end

def print_track(track)
  puts(track.name)
  puts(track.location)
end

def print_album(album)
    puts album.artist
    puts album.title
    puts('Genre is ' + album.genre.to_s)
    puts($genre_names[album.genre])
    print_tracks(album.tracks)
end

def main()
    music_file = File.new("album.txt", "r")
    album = read_album(music_file)
    music_file.close()
    print_album(album)
    
end

main()
