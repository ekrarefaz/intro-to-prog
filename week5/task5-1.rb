
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
  # Put a while loop here which increments an index to read the tracks
    while (!a_file.eof? ) 
        track = read_track(a_file)
        tracks[i] = track
        i += 1
    end
    #puts tracks

  return tracks
end

# reads in a single track from the given file.
def read_track(a_file)
  # complete this function
	# you need to create a Track here.

    while(!a_file.eof?)
        return a_file.gets()
    end
end


# Takes an array of tracks and prints them to the terminal
def print_tracks(tracks)
    i = 0
  # Use a while loop with a control variable index
  # to print each track. Use tracks.length to determine how
  # many times to loop.
  while i<tracks.length
    puts(tracks[i])
    i += 1
  end

  # Print each track use: tracks[index] to get each track record
end

# Takes a single track and prints it to the terminal
def print_track(track)
  puts(track.name)
  puts(track.location)
end

# Open the file and read in the tracks then print them
def main()
  a_file = File.new("file.txt", "r") # open for reading
  tracks = read_tracks(a_file)
  # Print all the tracks
  print_tracks(tracks)
end

main()
