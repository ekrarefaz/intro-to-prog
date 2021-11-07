# Author: Ekrar Uddin Mohammed Efaz
# StudentID: 103494172
# Program Name: Super Extented Music Player
# Attemping Grade: HD
# required dependencies: 'gosu', 'optparse', 'tk', 'input_functions.rb', 'colors.rb'
# *all the relative dependencies can be found in .lib folder in this directory*

#Code for the CLI mode of music player reused code from TEXT MUSIC PLAYER 7.1P with some alterations.

#for coloring of text
require_relative './.lib/colors' 

#Works on Linux with vlc installed 
#For Mac an alias must set to vlc system call via terminal
#Following commands for OSX:
#echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#echo "alias cvlc='/Applications/VLC.app/Contents/MacOS/VLC'" >> ~/.bash_profile
#Windows not supported
require 'vlc-client' #https://github.com/mguinada/vlc-client EXTERNAL PLAYER

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

def read_album_file()
    root = TkRoot.new
    root.title = "window"
    @filename = Tk::getOpenFile
    music_file = open(@filename,"r")
    if music_file
        albums = read_albums(music_file)
        music_file.close()
        root.destroy()
    else
        puts "Wrong Input"
        root.destroy()
    end
    return albums
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
	count = music_file.gets().to_i
	albums = Array.new
        while (0 < count)
            album = read_album(music_file)
            albums << album
            count -= 1
        end
	return albums
end

# ALBUM PRINTING
def print_album(album)
    puts ("Album artist : #{album.artist}")
    puts ("Album title : #{album.title}")
    puts('Genre ' + album.genre.to_s)
    puts(GENRE_NAMES[album.genre])
    print_tracks(album.tracks)
end

def print_albums(albums)
    puts albums.count
    count = albums.length
    i = 0
    while(i < count)
        print_album(albums[i])
        i += 1
    end
end

def print_tracks(tracks)
  i = 0
  while (i<tracks.length)
    print("Track ID #{i} - ".blue)
    print_track(tracks[i])
    i += 1
  end
end

def print_track(track) 
  print("Track Title: #{track.name}".red)
  print("Track Location: #{track.location}".red)
end

# 2 DISPLAY ALBUMS
def display_albums(albums)
    finished = false
    begin
        puts("Display Album".bg_blue)
        puts("1 - Display All Album".bg_brown)
        puts("2 - Display by Genre".bg_brown)
        puts("3 - Return to Main Menu".bg_brown)
        option = read_integer_in_range("Enter Choice: ", 1,3)
        case option
        when 1
            print_albums(albums)
        when 2
            print_albums_by_genre(albums)
        when 3
            puts("Returning to Main Menu..".bg_red)
            finished = true
        end
    end until finished
end

def print_albums_by_genre(albums) #prints an album when an album selected
    puts('Select Genre'.bg_blue)
    puts('1 Pop, 2 Classic, 3 Jazz , 4 Rock'.green)
    search_genre = read_integer('Enter number: ')
    i = 0
    while i < albums.length
        if search_genre == albums[i].genre
            print_album(albums[i])
        end
        i += 1
    end
end

def print_albums_artists(albums) #
    count = albums.length
    i = 0
    while(i < count)
        print("Artist #{i}--> ")
        print_album_artist(albums[i])
        i += 1
    end
end

def print_album_artist(album) #prints the title of artist 
    print(album.artist)
    return 
end

def print_album_title(album) #prints album title
    puts album.title
end

def print_albums_id(albums)
    count = albums.length
    i = 0 
    while(i < count)
        print("ID - #{i} -->> ".bg_brown)
        print_album_title(albums[i])
        i += 1
    end
end

# 3 PLAY ALBUMS
def play_album(albums)
    finished = false
    album = nil
    begin
        puts 'Play Albums:'.bg_blue
        puts '1 - Play by ID'.bg_cyan
        puts '2 - Search'.bg_cyan
        puts '3 - Return'.bg_cyan
        choice = read_integer_in_range("Option: ", 1, 3)
        case choice
        when 1
            album = search_id(albums)
            print_tracks(album.tracks)
            play_tracks(album.tracks)
        when 2
            album = search_menu(albums)
            print_tracks(album.tracks)
            play_tracks(album.tracks)
        when 3
            finished = true
        else
            puts 'Please select again'
        end
    end until finished
end

def search_id(albums) #search album by id
    print_albums_id(albums)
    puts("Select ID: ")
    id = read_integer_in_range("Enter ID ", 0 ,albums.count-1)
    return albums[id]
end

def search_by_artist(albums)
    print_albums_artists(albums)
    puts("Select Artist ID: ".green)
    id = read_integer_in_range("Enter ID ", 0 ,albums.count-1)
    return albums[id]
end

def search_by_genre(albums) #search albums by genre
    album = print_albums_by_genre(albums)
    return album
end

#plays specified track via vlc
def play_tracks(tracks)
    if (tracks.length != 0)
        track_id = read_integer_in_range("Enter Track ID: ",0, tracks.count-1)
        trackname = tracks[track_id].name
        track_location = tracks[track_id].location
        puts("Playing -- #{trackname}")
        vlc = VLC::System.new
        vlc.add_to_playlist(track_location)
        vlc.play
        puts("-- Player Loaded --".bg_blue())
    else
        puts("No Tracks\n".bg_red())
    end
end

# 3 > 2 SEARCH MENU
def search_menu(albums)
    finished = false 
    begin
        puts("1 - Search by Artist".bg_blue)
        puts("2 - Exit".bg_blue)
        option = read_integer_in_range("Enter Option: ", 1, 2)
        case option 
        when 1
            album = search_by_artist(albums)
            return album
            finished = true
        when 2
            puts("Exiting..".bg_blue.red)
            finished = true
        end
    end until finished
end

# 4 UPDATE ALBUM
def update_albums(albums)
    finished = false
    begin
        puts("1 - Update Title".bg_cyan)
        puts("2 - Update Genre".bg_cyan)
        puts("3 - Exit to Main Menu".bg_cyan)
        option = read_integer_in_range("Enter Option: ", 1, 2)
        case option
        when 1
            album = search_id(albums)
            update_title(album)
            puts("Press Enter")
            finished = gets()
        when 2
            album = search_id(albums)
            update_genre(album)
            puts("Press Enter")
            finished = gets()
        when 3
            puts("Exiting".bg_red)
            finished = true
        end until finished
    end
end

# Update Title
def update_title(album)
    finished = false 
    print("Title --> #{album.title}")
    new_title = read_string("New Title: ")
    album.title = new_title
    print_album_title(album)
end

#Update Genre
def update_genre(album)
    genre = album.genre
    puts("Genre --> #{genre} - #{$genre_names[genre]}")
    puts('1 Pop, 2 Classic, 3 Jazz , 4 Rock'.green)
    new_genre = read_integer_in_range("New Genre: ",1,4)
    album.genre = new_genre
end

# EXIT AND SAVE
def write_track track, music_file #save individual track
    music_file.puts track.name
    music_file.puts track.location
end

def write_tracks tracks, music_file #save all tracks by loop
    count = tracks.length
    music_file.puts(count)
    i = 0
    while (i < count)
        write_track(tracks[i], music_file)
        i += 1
    end
end

def save_album (album, music_file)  #save individual album
    music_file.puts (album.artist)
    music_file.puts (album.title)
    music_file.puts (album.artwork)
    music_file.puts (album.genre)
    write_tracks(album.tracks, music_file)
end

def save_albums(albums, music_file) #save all albums by loop
    count = albums.length
    music_file.puts(count)
    i = 0
    while(i < count )
        save_album(albums[i], music_file)
        i += 1
    end
end

def save_file_changes(albums)   #save changes to file by writing.
    if @filename
        music_file = File.new(@filename, "w")
        if music_file
            save_albums(albums,music_file)
            music_file.close()
        else
            puts ("FILE LOAD FAIL".bg_red)
        end
    else
        puts("ERROR 404")
    end
end
# MAIN MENU
def main_menu_albums()
    finished = false
    begin
    puts 'Main Menu:'.bg_blue
    puts '1 - Read Album'.bg_cyan
    puts '2 - Display Album'.bg_cyan
    puts '3 - Play Album'.bg_cyan
    puts '4 - Update Album'.bg_cyan
    puts '5 - Exit'.bg_cyan
    choice = read_integer_in_range("Option: ", 1, 5)
        case choice
        when 1
            albums = read_album_file()
            @album_read = true
        when 2
            if @album_read
                display_albums(albums)
            else
                puts("Please Read Album First".red)
            end
        when 3
            if @album_read
                play_album(albums)
            else
                puts("Please Read Album First".red)
            end
        when 4
            if @album_read
                update_albums(albums)
            else
                puts("Please Read Album First".red)
            end
        when 5
            save_file_changes(albums)
            puts("Exiting Application".bg_red.gray)
            finished = true
        else
            puts 'Please select again'
        end
    end until finished
end

# MAIN

