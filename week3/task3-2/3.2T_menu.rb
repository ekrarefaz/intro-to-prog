require './input_functions'
# a stub for Main Menu Option 1 Album update
def maintain_albums()

    continue = false
    begin
        print("\n")
        puts("Maintain Albums Menu: ")
        puts("1 To Update Album Title")
        puts("2 To Update Album Genre")
        puts("3 To Enter Album")
        puts("4 Return to the main menu")
        puts("\n")
        option = read_integer_in_range("Please Enter your choice", 1,4)
        # enter a number for choice
        case option
        when 1
            puts("You selected update album title")
            puts("\n")
            print("-----TITLE UPDATE MENU-----\n")
            input = read_string("Press enter to continue")
        when 2
            puts("You selected to Update album genre")
            puts("\n")
            print("-----GENRE UPDATE MENU-----\n")
            input = read_string("Press enter to continue")
        when 3
            puts("You selected to enter album")
            puts("\n")
            print("-----ENTERING ALBUM...-----\n")
            input = read_string("Press enter to continue") 
        when 4
            puts("Returning to the main menu...")
            puts("\n")
            continue = true
        end
    end until continue
end
# a stub for Main Menu Option 2: Play existing Album
def play_existing_album()
  puts("You selected Play Existing Album\n")
  puts("-----PLAYER STARTING-----\n")
  puts("Press enter to continue")
  input = gets.chomp()
end

def main()
  finished = false
  begin
    puts('Main Menu:')
    puts('1 To Enter or Update Album')
    puts('2 To Play Existing Album')
    puts('3 Exit')
    puts("\n")
    choice = read_integer_in_range("Please enter your choice:", 1, 3)
    # enter a number for choice
    case choice
    when 1
      maintain_albums()
	  when 2
      play_existing_album()
    when 3
        puts("Exiting...")
        finished = true
    else
      puts('Please select again')
    end
  end until finished
end
# main function call
main()
