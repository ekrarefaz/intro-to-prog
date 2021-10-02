require './input_functions'

# Complete the code below
# Use input_functions to read the data from the user
class Computer
    attr_accessor :id, :manufacturer, :model, :price
    def initialize(id, manufacturer, model, price)
        @id = id
        @manufacturer = manufacturer
        @model = model
        @price = price
    end
end

def read_computer()
    id = read_integer('Enter Computer ID: ')
    manufacturer = read_string('Enter Manufacturer Name: ')
    model = read_string('Enter Computer Model: ')
	price = read_float('Enter price:')
    computer = Computer.new(id, manufacturer, model, price)
    return computer
end

def read_computers()
    num = read_integer('How many computers are you entering: ')
    i = 0
    computers = Array.new()
    while (i < num)
        computer = read_computer()
        computers << computer
        i += 1
    end
    return computers
end

def print_computer(computer)
    puts("Computer ID is:  #{computer.id}")	
    puts("Computer Manufacturer name is #{computer.manufacturer}")
    puts("Computer Model is: #{computer.model}")
    printf("Price: %.2f\n", computer.price)
end

def print_computers(computers)
    i = 0
    while(i < computers.length)
        computer = computers[i]
        print_computer(computer)
        i += 1
    end
	#printf("Price: %.2f\n", computer.price)
end

def main()
	computers = read_computers()
	print_computers(computers)
end

main()