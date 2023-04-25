#!/bin/bash
# global variables
num_recipes=$(ls recipes | wc -l)
# Create and populate database with recipes, add search functionality
# Be able to search by recipe title, recipe tags/category (ie. Soup, seafood, dessert, etc), find what recipes I can make with the ingredients I have or with given ingredients
function search(){
        printf "\n*** Search Recipe Catalog ***\n"
        printf "If searching by tag\(s\), enter \"tag: <tag1>,<tag2>,...\".\n"
        printf "To view all, enter \"all\".\n"
        printf "Hit <Enter> to return to the main menu.\n\n"
        read -p "What recipe would you like to find? " recipe
        while [ ! -z "$recipe" ]; do
		# search all
                if [ "$recipe" == "all" ]; then
                        cat recipes_list | grep -v "tag" | grep -v "id" | sort -f
			read -p "Would you like to open a recipe? If so, enter name of recipe. Otherwise, hit <Enter>. " r
                        if [ ! -z "$r" ]; then
                                if grep -Eiq "$r" recipes_list; then

                                        id=$(grep -i -A2 "$r" recipes_list | sed '1,2d' | sed -r 's/^id: ([0-9]+)$/\1/')
                                        more recipes/$id
                                else
                                        printf "No recipe found.\n\n"
                                fi
                        fi
                # search tags
                elif echo "$recipe" | grep -q "tag"; then
			cat recipes_list>temp 
			IFS=',' tags=$(echo "$recipe" | sed -r 's/tag: //')
			read -ra tag_array<<<"$tags"
			for t in "${tag_array[@]}"; do 
				grep -Ei -B1 "tags: .*$t" temp > temp2
				cat temp2>temp 
			done
			cat temp
			rm -f temp 
			rm -f temp2
			read -p "Would you like to open a recipe? If so, enter name of recipe. Otherwise, hit <Enter>. " r
                        if [ ! -z "$r" ]; then
                                if grep -Eiq "$r" recipes_list; then

                                        id=$(grep -i -A2 "$r" recipes_list | sed '1,2d' | sed -r 's/^id: ([0-9]+)$/\1/')
                                        more recipes/$id
                                else
                                        printf "No recipe found.\n\n"
                                fi
                        fi
		# search title
                elif grep -i "$recipe" recipes_list | grep -v "tag"; then
                        read -p "Would you like to open a recipe? If so, enter name of recipe. Otherwise, hit <Enter>. " r
                        if [ ! -z "$r" ]; then
				if grep -Eiq "$r" recipes_list; then

                                	id=$(grep -i -A2 "$r" recipes_list | sed '1,2d' | sed -r 's/^id: ([0-9]+)$/\1/')
                                	more recipes/$id
				else
					printf "No recipe found.\n\n"
				fi
                        fi
                # no title found
                else
                        printf "No recipe found.\n\n"
                fi
                read -p "What recipe would you like to find? " recipe
	done
}
function add(){
        printf "\n*** Add Recipe ***\n"
        printf "Hit <Enter> to return to the main menu. Otherwise, fill prompts to create new recipe. \n\n"
        read -p "Title: " title
        if [ ! -z "$title" ]; then
         	id=$((num_recipes + 1))	
		echo "$title" > "recipes/$id"
                read -p "Difficulty: " difficulty
				echo "Difficulty: $difficulty" >> "recipes/$id"
                read -p "How much does this make? " servings
				echo "Makes: $servings" >> "recipes/$id"
				echo "" >> "recipes/$id"
                read -p "Tags: " tags
                read -p "Enter ingredients, separated by return. Hit <Enter> when done: " ingredients
				while [ ! -z "$ingredients" ]; do
					echo "$ingredients" >> "recipes/$id"
					read ingredients
				done
                read -p "Instructions: " instructions
               
                echo "" >> "recipes/$id"
                echo "$instructions" >> "recipes/$id"

                # append to recipes list
                echo "$title">>"recipes_list"
                echo "tags: $tags">>"recipes_list"
                echo "id: $id">>"recipes_list"
                num_recipes=$id
				echo ""
                printf "Created new recipe $title.\n" 
	fi
}
function share(){
	printf "\n*** Share Recipe ***\n"
    printf "Hit <Enter> to return to the main menu. Otherwise, fill prompts to share recipe. \n\n"
    read -p "Enter recipe title from catalog: " recipe
	if [ ! -z "$recipe" ]; then
			if grep -Eiq "$recipe" recipes_list; then
                        id=$(grep -i -A2 "$recipe" recipes_list | sed '1,2d' | sed -r 's/^id: ([0-9]+)$/\1/')
			read -p "Enter recipient's email address: " email
			cat recipes/$id | mail -s "$recipe" "$email"
			printf "Email sent.\n\n"
		else
			printf "No recipe found.\n\n"
		fi
    fi

}
function search_inv(){
	printf "\n*** Search and Edit Inventory ***\n"
	printf "To view inventory, enter \"view\".\n"
	printf "To add items to inventory, enter \"add\".\n"
	printf "To delete items from inventory, enter \"del\".\n"
    printf "Hit <Enter> to return to the main menu.\n\n"
        read -p "What ingredient would you like to search for? " i
        while [ ! -z "$i" ]; do
		if [ "$i" == "view" ]; then
                        cat inventory
                # add ingredients to inventory
                elif [ "$i" == "add" ]; then
                    read -p "Enter ingredients, separated by return. Hit <Enter> when done: " ingredients
                    while [ ! -z "$ingredients" ]; do
                        echo "$ingredients" >> inventory
                        read ingredients
                    done
		                # delete ingredients from inventory
                elif [ "$i" == "del" ]; then 
                        read -p "Enter ingredients, separated by return. Hit <Enter> when done: " ingredients
                        while [ ! -z "$ingredients" ]; do
                                sed -i "/$ingredients/d" inventory
                                read ingredients
                        done
		 elif grep -Eiq "$i" inventory; then
                        printf "You have this in your inventory.\n"
		
		 else
                    read -p "Ingredient not found. Add to shopping list? y/n " op
                                        if [ "$op" == "y" ]; then
                                                if grep -Eiq "$i" shopping_list; then
                                                        printf "Already in shopping list.\n"
                                                else
                                                        echo "$i" >> shopping_list
                                                        printf "Added to list.\n"
                                                fi
			fi
		fi
                read -p "What ingredient would you like to search for? " i
	done
}
function shopping_list(){
printf "\n*** Search and Edit Shopping List ***\n"
        printf "To view shopping list, enter \"view\".\n"
        printf "To add items to shopping list, enter \"add\".\n"
        printf "To delete items from shopping list, enter \"del\".\n"
    printf "Hit <Enter> to return to the main menu.\n\n"
        read -p "What ingredient would you like to search for? " i
        while [ ! -z "$i" ]; do
                # view all
                if [ "$i" == "view" ]; then
                        cat shopping_list
                # add ingredients to shopping list
                elif [ "$i" == "add" ]; then
                    read -p "Enter ingredients, separated by return. Hit <Enter> when done: " ingredients
                    while [ ! -z "$ingredients" ]; do
                        echo "$ingredients" >> shopping_list
                        read ingredients
                    done
                                # delete ingredients from inventory
                elif [ "$i" == "del" ]; then 
                        read -p "Enter ingredients, separated by return. Hit <Enter> when done: " ingredients
                        while [ ! -z "$ingredients" ]; do
                                sed -i "/$ingredients/d" shopping_list
                                read ingredients
                        done
                # search by ingredient name
                elif grep -Eiq "$i" shopping_list; then
                        printf "You have this in your shopping list.\n"
                # no title found
                else
                    read -p "Ingredient not found. Add to shopping list? y/n " op
                                        if [ "$op" == "y" ]; then
                                                        echo "$i" >> shopping_list
                                                        printf "Added to list.\n"
												fi
                fi
                read -p "What ingredient would you like to search for? " i
        done
}
function inventory(){
	printf "\n*** Inventory ***\n"
    printf "\t[1] Search and edit inventory\n\t[2] View and edit shopping list\n\t<Enter> to return to main menu.\n"
  read option
  while [ ! -z "$option" ]; do
    case "$option" in
      1)
        search_inv
        ;;
      2)
        shopping_list
		;;
      *)
        printf "Invalid option.\n"
        ;;
    esac
    printf "\t[1] Search and edit inventory\n\t[2] View and edit shopping list\n\t<Enter> to return to main menu.\n"
    read option
  done
}
function menu(){
printf "\nWelcome to the recipe catalog! What would you like to do?\n"
printf "\t[1] Search recipes\n\t[2] Add recipe\n\t[3] Share recipe\n\t[4] Inventory\n\t[<Enter> or CTRL+D] Quit\n"  
read option
  while [ ! -z "$option" ]; do
    case "$option" in
      1)
        search
        ;;
      2)
	add
        ;;
      3)
	share
	;;
      4)
	inventory
	;;
      *)
        printf "Invalid option.\n"
        ;;
    esac
    printf "\nWelcome to the recipe catalog! What would you like to do?\n"
      printf "\t[1] Search recipes\n\t[2] Add recipe\n\t[3] Share recipe\n\t[4] Inventory\n\t[<Enter> or CTRL+D] Quit\n"
    read option
  done
  printf "Shutting down...\n"
  exit 0
}
menu
