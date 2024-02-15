#!/bin/bash

# Path to the text file containing quotes
QUOTES_FILE="/home/conor/.config/scripts/data/quotes.txt"

# Count the number of lines in the quotes file
num_lines=$(wc -l < "$QUOTES_FILE")

# Generate a random line number
random_line=$((1 + RANDOM % num_lines))

# Retrieve the quote at the random line number
quote=$(sed -n "${random_line}p" "$QUOTES_FILE")

# Display the quote via notification
notify-send -t 0 'Quote of the day!' "$quote" --icon=dialog-information
