# writes the number of lines then each line as a string.

def write_data_to_file(filename)
    a_file = File.new(filename, "w")
    #a_file.puts('5')
    a_file.puts('Fred')
    a_file.puts('Sam')
    a_file.puts('Jill')
    a_file.puts('Jenny')
    a_file.puts('Zorro')
    a_file.close()
 end
 
 # reads in each line.
 # you need to change the following code
 # so that it uses a loop which repeats
 # acccording to the number of lines in the File
 # which is given in the first line of the File
 def read_data_from_file(filename)
   a_file = File.new(filename, "r")
   # puts a_file.class
   #count = a_file.gets.to_i()
   #puts count.to_s()
   #puts a_file.gets()
   #puts a_file.gets()
   #puts a_file.gets()
   #puts a_file.gets()
   #puts a_file.gets()
   while (!a_file.eof?)
     puts a_file.gets()
   end
   a_file.close()
 end
 
 # writes data to a file then reads it in and prints
 # each line as it reads.
 # you should improve the modular decomposition of the
 # following by moving as many lines of code
 # out of main as possible.
 def main
    # open for writing
   write_data_to_file("notmyfile.txt")
   
   
    # open for reading
   read_data_from_file("notmyfile.txt")
  
 end
 
 main
 
 