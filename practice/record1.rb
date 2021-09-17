class Dog 
    attr_accessor :id, :breed, :color, :age
    def initialize(id, breed, color, age)
        @id = id
        @breed = breed
        @color = color
        @age = age
    end
end
def read_dog()
    id = gets.to_i()
    breed = gets()
    color = gets()
    age = gets.to_i()
    return id, breed, color, age
    
end
def main()
    dog1 = read_dog()
    new_dog = Dog.new(dog1[0],dog1[1],dog1[2],dog1[3])
    puts new_dog
    puts (new_dog.id)
    puts (new_dog.breed)
    puts (new_dog.color)
    puts (new_dog.age)
end

main()