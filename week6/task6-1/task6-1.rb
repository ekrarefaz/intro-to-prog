require './input_functions'

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

# Returns an array of tracks read from the given file
def read_tracks(a_file)
  count = a_file.gets().to_i()
  tracks = Array.new()
  i = 0 
  while (i < count) 
    track = read_track(a_file)
    tracks[i] = track
    i += 1
  end
  print_tracks(tracks)
  return tracks
end

# reads in a single track from the given file.
def read_track(a_file)
  name = a_file.gets()
  location = a_file.gets()
  return Track.new(name, location)
end

# Takes an array of tracks and prints them to the terminal
def print_tracks(tracks)
  i = 0
  while (i<tracks.length)
    print_track(tracks[i])
    i += 1
  end
end

# Takes a single track and prints it to the terminal
def print_track(track)
  puts(track.name)
  puts(track.location)
end

# Open the file and read in the tracks then print them
def search_for_track_name(tracks, search_string)
    i = 0
    while(i <= tracks.length)
      if tracks[i].name.chomp == search_string.chomp
        return i
        break
      end
      i += 1
    end
    return -1
end

def matcher(string, search_string)
# ???
end

def main()
    a_file = File.new("album.txt", "r")
    tracks = read_tracks(a_file)
    a_file.close()

    search_string = read_string("Enter the track name you wish to find: ")
    index = search_for_track_name(tracks, search_string)

    if index > -1
      puts "Found " + tracks[index].name + " at " + (index).to_s()
    else
      puts "Entry not Found"
    end
end

main()
