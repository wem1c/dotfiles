#!/bin/bash
#
# Wait for an internet connection and run a script.

source home/conor/.config/scripts/lib/internet-check.sh

# Set the timeout for waiting for an internet connection
TIMEOUT_SECONDS=60

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <script_file>"
  exit 1
fi

# Get the script file path from the command line argument
script_file="$1"

# Check if the script file exists
if [ ! -f "$script_file" ]; then
  echo "Error: Script file '$script_file' not found."
  exit 1
fi

wait_for_internet

# Run the script
"$script_file"
