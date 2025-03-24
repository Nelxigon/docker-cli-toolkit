#!/bin/bash

#1: Variable with the container ids
#2: Integer representation of the string below
#3: String with the operation, e.g. "Stopped container"
container_loop() {
	len=$(echo -e "$1" | wc -l)
	for i in $(seq 1 $len)
	do
		info=$(echo -e "$1" | awk -v var="$i" 'NR == var')
		if [[ "$2" == "1" ]]; then
			docker stop "$info"
		elif [[ "$2" == "2" ]]; then
			docker remove "$info"
		elif [[ "$2" == "3" ]]; then
			docker rmi "$info"
		else
			echo -e "Error occured while processing. Please check the code for any bugs and try again."
		fi
		echo "$3 $info."
	done
}

stop_containers() {
	containers=$(docker ps)
	ids=$(docker ps | awk 'NR > 1 { print $1 }')

	if [[ "$ids" == "" ]]; then
		echo "You chose to stop docker containers. Unfortunately, there are no running docker containers to stop."
		choose_option
	else
		echo "You chose to stop docker containers. Do you want to stop all containers at once or decide for each one individually?"
		echo -n "Running containers:"
		echo "$containers"
		echo -n "Stop all containers at once? (default: Y) [Y/n] "
		read choice

		if [[ "$choice" == "y" ]] || [[ "$choice" == "yes" ]] || [[ "$choice" == "" ]]; then
			container_loop "$ids" 1 "Stopped container"
		elif [[ "$choice" == "n" ]] || [[ "$choice" == "no" ]]; then
			echo "Operation aborted. Returning to main menu..."
			choose_option
			break
		else
			echo "Unknown input. Operation aborted. Returning to main menu..."
			choose_option
			break
		fi

		echo "Successfully closed all containers! Returning to main menu..."
		choose_option
	fi
}

remove_containers() {
	containers=$(docker ps -a)
	ids=$(docker ps -a | awk 'NR > 1 { print $1 }')
	
	if [[ "$ids" == "" ]]; then
		echo "You chose to remove docker containers. Unfortunately, you have no docker containers."
		choose_option
	else
		echo "You chose to remove docker containers. Do you want to remove all containers at once or decide for each one individually?"
		echo -n "Available containers:"
		echo "$containers"
		echo -n "Remove all containers at once? (default: Y) [Y/n] "
		read choice

		if [[ "$choice" == "y" ]] || [[ "$choice" == "yes" ]] || [[ "$choice" == "" ]]; then
			container_loop "$ids" 2 "Removed container"
		elif [[ "$choice" == "n" ]] || [[ "$choice" == "no" ]]; then
			echo "Operation aborted. Returning to main menu..."
			choose_option
			break
		else
			echo "Unknown input. Operation aborted. Returning to main menu..."
			choose_option
			break
		fi

		echo "Successfully removed all containers! Returning to main menu..."
		choose_option
	fi
}

remove_images() {
	images=$(docker image list)
	ids=$(docker image list | awk 'NR > 1 { print $3 }')

	if [[ "$ids" == "" ]]; then
		echo "You chose to remove docker images. Unfortunately, you have no docker images."
		choose_option
	else
		echo "You chose to remove docker images. Do you want to remove all images at once or decide for each one individually?"
		echo -n "Available images:"
		echo "$images"
		echo -n "Remove all images at once? (default: Y) [Y/n] "
		read choice

		if [[ "$choice" == "y" ]] || [[ "$choice" == "yes" ]] || [[ "$choice" == "" ]]; then
			container_loop "$ids" 3 "Removed image"
		elif [[ "$choice" == "n" ]] || [[ "$choice" == "no" ]]; then
			echo "Operation aborted. Returning to main menu..."
			choose_option
			break
		else
			echo "Unknown input. Operation aborted. Returning to main menu..."
			choose_option
			break
		fi

		echo "Successfully removed all images! Returning to main menu..."
		choose_option
	fi
}

all_in_one() {
	running=$(docker ps | awk 'NR > 1 { print $1 }')
	containers=$(docker ps -a | awk 'NR > 1 { print $1 }')
	images=$(docker image list | awk 'NR > 1 { print $3 }')

	if [[ "$running" == "" ]] && [[ "$containers" == "" ]] && [[ "$images" == "" ]]; then
		echo "There's nothing to do :) You have no available containers or images. Exiting program..."
		exit 0
	else
		echo "You chose to do all in one. If you want to choose action for each container individually, please consider the other options."
		echo -n "Proceed? This will stop all running docker containers, remove them and remove all images! (default: Y) [Y/n] "
		read choice

		if [[ "$choice" == "y" ]] || [[ "$choice" == "yes" ]] || [[ "$choice" == "" ]]; then
			container_loop "$running" 1 "Stopped container"
			container_loop "$containers" 2 "Removed container"
			container_loop "$images" 3 "Removed image"
		elif [[ "$choice" == "n" ]] || [[ "$choice" == "no" ]]; then
			echo "Operation aborted. Returning to main menu..."
			choose_option
			break
		else
			echo "Unknown input. Operation aborted. Returning to main menu..."
			choose_option
			break
		fi

		echo "Successfully cleaned up everything! Exiting program..."
		exit 0
	fi
}

choose_option() {
	while true; do
		echo -e "\e[32m[s]\e[0m - stop containers\t\e[33m[c]\e[0m - remove containers\n\e[33m[i]\e[0m - remove images\t\e[31m[a]\e[0m - all in one"
		echo -n "Select choice to continue. (default: A, all in one) [s/c/i/A] "
		read user_choice

		if [[ "$user_choice" == "s" ]]; then
			stop_containers
			break
		elif [[ "$user_choice" == "c" ]]; then
			remove_containers
			break
		elif [[ "$user_choice" == "i" ]]; then
			remove_images
			break
		elif [[ "$user_choice" == "a" ]] || [[ "$user_choice" == "" ]]; then
			all_in_one
			break
		else
			echo -e "Unknown option. Please select one of the options below:"
		fi
	done
}

# Main Function
echo -e "\e[0mWelcome to the easy docker management tool. What do you want to do today?"
choose_option
