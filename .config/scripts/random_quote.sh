#!/bin/bash

# Path to the text file containing quotes
QUOTES_FILE="/home/conor/.config/scripts/quotes.txt"
BUS_ADDRESS="unix:path=/run/user/1000/bus"

# Count the number of lines in the quotes file
num_lines=$(wc -l < "$QUOTES_FILE")

# Generate a random line number
random_line=$((1 + RANDOM % num_lines))

# Retrieve the quote at the random line number
quote=$(sed -n "${random_line}p" "$QUOTES_FILE")

# Display the quote via notification
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send -t 0 'Quote of the day!' "$quote" --icon=dialog-information
