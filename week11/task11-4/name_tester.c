#include <stdio.h>
#include <string.h>
#include "terminal_user_input.h"

#define LOOP_COUNT 60

void print_silly_name(name){
    int i = 0;
    printf("%s",name);
    for(i;i<60;i++){
        printf(" a silly, ");
    }
}
int main(){
    my_string name;
    printf("Your name ");
    name = read_string("What is your name? ");

    if(strcmp(name.str,"Muhammad") == 0){
          printf("is an Awesome Name!");
    }
    else{
          print_silly_name(name);
          printf("\nname!\n");
    }
    return 0;
}
