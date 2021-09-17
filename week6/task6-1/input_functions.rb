
# Display the prompt and return the read string
def read_string golam
	puts golam
	value = gets.chomp
	return value
end

# Display the prompt and return the read float
def read_float golam
	value = read_string(golam)
	value.chomp.to_f
end

# Display the prompt and return the read integer
def read_integer golam
	value = read_string(golam)
	value.to_i
end

# Read an integer between min and max, prompting with the string provided

def read_integer_in_range(golam, min, max)
	value = read_integer(golam)
	while (value < min or value > max)
		puts "Please enter a value between " + min.to_s + " and " + max.to_s + ": "
		value = read_integer(golam);
	end
	value
end

# Display the prompt and return the read Boolean

def read_boolean golam
	value = read_string(golam)
	case value
	when 'y', 'yes', 'Yes', 'YES'
		true
	else
		false
	end
end

def print_float(value, decimal_places)
	print(value.round(decimal_places))
end

# Test the functions above
'''begin
def main
	puts "String entered is: " + read_string("Enter a String: ")
	puts "Boolean is: " + read_boolean("Enter yes or no:").to_s
	puts "Float is: " + read_float("Enter a floating point number: ").to_s
	puts "Integer is: " + read_integer_in_range("Enter an integer between 3 and 6: ", 3, 6).to_s
end

main
end'''
