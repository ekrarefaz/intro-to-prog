# write code that reads in a user's name from the terminal.  If the name matches
# your name or your tutor's name, then print out "<Name> is an awesome name!"
# Otherwise call a function called print_silly_name(name) - which you must write -
# that prints out "<Name> is a " then print 'silly' (60 times) on one long line
# then print ' name.'

def print_silly_name(name):
    # complete this
    index = 0
    print(name, "is a")
    while (index < 60):
        index += 1
        print("silly", end=" ")
    print("name!")


def main():
    name = input("What is your name?\n")
    if (name == "Mumu") or (name == "Muhammad"):
        print(name + " is an awesome name!")
    else:
        print_silly_name(name)
    return


main()
