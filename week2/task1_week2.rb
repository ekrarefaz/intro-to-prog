# Have a look at the following file to see what functions it contains.
# These are available to be used in this program because of the following
# line - you DO NOT need to copy them into this file:
require './input_functions'

def read_patient_name()
	# write this function - use the function read_string(s)
	# from input_functions.rb to read in the name as follows:
	name = read_string('Enter patient name: ')
	# make sure you 'return' the name you read to the calling module
end

def calculate_accommodation_charges()
	charge = read_float("Enter the accommodation charges: ")
	return charge
end

def calculate_theatre_charges()
	charge = read_float("Enter the theatre charges: ")
	return charge
end

def calculate_pathology_charges()
	# complete this function based on the above examples
    charge = read_float("Enter the pathology charges: ")
	return charge
end

def print_patient_bill(name, total)
	# write this procedure to print out the patient name
	# and the bill total - use the procedure (from input_functions)
	# print_float(value, decimal_places) to print the total
    puts("patient name : #{name}")
    print_float(total, 2)
end

def create_patient_bill()
	total = 0 # it is important to initialise variables before use!
	patient_name = read_patient_name()
	total += calculate_accommodation_charges()
	total += calculate_theatre_charges()
	total += calculate_pathology_charges()
	print("Total bill is ")
    print_patient_bill(patient_name, total)
end

def main()
	create_patient_bill()
end

main()
