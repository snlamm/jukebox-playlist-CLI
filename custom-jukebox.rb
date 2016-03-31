require_relative "./playlists"
require 'pry'

def help
  i = ["I accept the following commands:",
  "- help : displays this help message",
  "- list : displays a list of songs you can play",
  "- play : lets you choose a song to play",
  "- exit : exits this program"]
  puts i
end

#splits combined file paths in playlists.rb into an arrays of individual file paths.
#Each album has its own array of file paths
def split_songs
  songs_array = []
  #each song is now a separate item, including /Users/
  # regexp: the first /'s indicate a regexp matching. The ?= indicates that the delimeter for .split should
  # still be included in the split string. the \'s indicate that /'s around Users are string
  # rather than a special charachter for regexp.
  playlists.each {|playlist_name, songs| songs_array << songs.split(/(?=\/Users\/)/)}
  songs_array
end

#translates individual file paths from def split_songs into song names and numbers
def organize_songs
  songs_array = split_songs
  completed_songs_array = []
  songs_array.each do |album|
    album_songs_array = []
    album.each_with_index do |song, index|
      song_breakdown = song.split(" ")
      #find which beginning keyword the song uses. convert the beginning keyword to an array index number
      beginning = song_breakdown.index(song_breakdown.find {|word| word.include?("Album" || "Volume")}) 
      #find which ending keyword the song uses. convert the ending keyword to an array index number
      ending = song_breakdown.index(song_breakdown.find {|word| word.include?(".mp3")}) 
      #Add song numbers. Parse song addresses into song names
      album_songs_array << "#{(index + 1)}. #{song_breakdown[((beginning + 1)...ending)].join(" ").delete('\\')}" 
    end
    #the songs of each album are separately shoveled into a super-array so that each album is a separate item
    completed_songs_array << album_songs_array 
  end
  songs_hash = {}
  # Ex. => {"How to Train Your Dragon"=>{}, "Mulan"=>{}}
  playlists.keys.each {|album_title| songs_hash[album_title] = {}} 
  #converts album name and album songs into key/value pairs
  (0..(playlists.size - 1)).each {|num| songs_hash[playlists.keys[num]] = completed_songs_array[num]}
  songs_hash
  #binding.pry # try doing puts songs_hash["Mulan"] and see the result!
end


#promots user for input of an album title and puts songs in that album
def list
  song_list = organize_songs
  puts "Which album do you want to inspect? (Type the last word (and number) in the album title)." 
  puts "Type 'albums' to see a list of album titles"
  album_name = gets.chomp
  album_name.upcase!
  if album_name == "ALBUMS"
    puts song_list.keys
  elsif song_list.keys.join(" ").include?(album_name)
    song_list.keys.each {|title| puts song_list[title] if title.include?(album_name)}
  else
    puts "Sorry, but there is no album of that name."  
    puts "Type 'list' to try again"
  end
end

#Prompts user for input of an album and song number to play.
#In runner, set equal to 'selection'.
def user_choice 
  song_list = organize_songs
  puts "Please enter the album and number of the song you wish to play, separated by a colon."
  puts "Ex. Typing 'Dragon 1: 8' will play How to Train Your Dragon 1, song 8"
  puts "Ex. Entering 'Mulan: 5' will play Mulan, song 5"
  song_name = gets.chomp
  song_name = song_name.upcase.split(": ")
end

#Locates the album input by user in def user_choice
def find_album(selection)
  song_list = organize_songs
  song_name = selection
  # find album title
  if song_list.keys.join(" ").include?(song_name[0])
    album = song_list.keys.select {|title| title.include?(song_name[0])}
    #if no albums match the input name
    if album.size < 1
      puts "Sorry, no album title fits that name."
      puts "Type 'play' to try again or use 'list' to find the desired album name."
    # if more than one album matches the input name, the one with the fewest words is chosen
    elsif album.size > 1
      return album_title = album.sort_by {|name| name.split.size}[0] 
    elsif album.size == 1
      return album_title = album[0]
    end
  else
    puts "Sorry, no album title fits that name."
    puts "Please try again using 'play' or use 'list' to find the desired album name."
  end
end

#Locates and plays the input song number from the input album name
def play_song(selection)
  song_list = organize_songs
  song_name = selection
  album_title = find_album(selection)
  songs_array = split_songs
  if album_title == nil
  elsif song_name[1] == nil || song_list[album_title].size < song_name[1].to_i 
    puts "Sorry, there's no song by that number in #{album_title}"
  else 
    #songs_array is an array of song file paths, split into separate arrays by album name.
    #song_list.keys is an array of the album titles
    #songs_array..(album_title) selects the index number in songs_array that corresponds to the correct album
    #[(song_name[1].to_i -1) is the index number of the desired song within album sub-array
    #the final clause gets ride of the empty " " at the end of the file path
    song_to_play = songs_array[song_list.keys.index(album_title)][(song_name[1].to_i - 1)][(0...-1)]
    system "open #{song_to_play}"
  end
end

def exit_jukebox
  puts "Goodbye"
end


def runner
  help
  exit_command = false
  until exit_command == true
    choice = gets.chomp
    choice.downcase!
    case choice
    when "help"
      help
    when "list"
      list
    when "play"
      selection = user_choice
      play_song(selection)
    when "exit"
      exit_jukebox
      exit_command = true
    else 
     puts "That was not a valid selection."
     puts "Please type 'help', 'list', 'play', or 'exit'."
    end
  end
end





