#!/bin/bash


function menu(){
printf "\nWelcome to the recipe catalog! What would you like to do?\n"
  printf "\t[1] Search\n\t[2] Checkout books\n\t[3] Read book\n\t[<Enter> or CTRL+D] Quit\n"
  read option
  while [ ! -z "$option" ]; do
    case "$option" in
      1)
        search
        ;;
      2)
        if [ ${#inventory[@]} -eq 10 ]; then
			echo "You have checked out the maximum number of books allowed."
		else
			checkout
		fi
        ;;
      3)
        read_book
	;;
      *)
        printf "Invalid option.\n"
        ;;
    esac
    printf "\nWelcome to the recipe catalog! What would you like to do?\n"
    printf "\t[1] Search\n\t[2] Checkout books\n\t[3] Read book\n\t[<Enter> or CTRL+D] Quit\n"
    read option
  done
  printf "Shutting down...\n"
  exit 0
}
menu
