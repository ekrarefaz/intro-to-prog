require 'date'
require './input_functions'

# Multiply metres by the following to get inches:
INCHES = 39.3701

# Insert into the following your hello_user code
# from task 1.3P and modify it to use the functions
# in input_functions

def main()

  # HOW TO USE THE input_functions CODE
  # Example of how to read strings:

  name = read_string('What is your name? ')
  fam_name = read_string("what is your family name?")
  
  year_born = read_integer('WHat year were you born?').to_i()
  puts("So you are #{Date.today.year - year_born} years old")
  
  height_in_meters = read_float("Enter your height in meters(i.e as a float):")
  puts("Your height in inches is:")

	height_in_inches = height_in_meters * INCHES
	puts('Your height in inches is: ')
	puts(height_in_inches.to_s())

  continue = read_boolean('Do you want to continue?')
  if (continue)
	  puts("Ok, lets continue")
  else
    puts("ok, goodbye")
  end

	 # Now if you know how to do all that
   # Copy in your code from your completed
	 # hello_user Task 1.3 P. Then modify it to
	 # use the code in input_functions.
   # use read_string for all strings (this will
   # remove all whitespace)
end

main()

