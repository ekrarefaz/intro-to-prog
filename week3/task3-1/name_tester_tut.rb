require './input_functions'

# you need to complete the following procedure that prints out 
# "<Name> is a " then print 'silly' (60 times) on one long line
# then print ' name.' \newline

def print_silly_name(name)
	puts(name + " is a")
	# complete the code needed here - you will need a loop.
	i = 0 
	while (i <= 60 ) do
		print('silly ')
		i+=1
	end
	puts(' name!')
end

# copy your code from the previous stage below and 
# change it to call the procedure above, passing in the name:
def main
  name = read_string("What is your name?")
  if name == "Muhammad" or name == "Islam" or name == "muhammad" or name == "islam"
    puts "#{name} is an awesome name"
  elsif name == "Ekrar" or name == "Efaz" or name == "ekrar" or name == "efaz"
    puts "#{name} is an awesome name"
  else
    print_silly_name(name)
  end
end

# put your main() from stage one here

main()

