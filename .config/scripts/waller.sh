#! /usr/bin/bash

# This script grabs the top wallpaper of the day from r/wallpaper!

# Function to notify errors and exit with a specific status code
notify_error() {
    local message="$1"
    env DBUS_SESSION_BUS_ADDRESS="$BUS_ADDRESS" notify-send 'Waller encountered an error!' "$message" --icon=dialog-error
    exit 1
}

# Function to clean up temporary files
cleanup() {
    rm main.html wp.html "$output_file"
}

# Will echo passed parameters only if DEBUG is set to a value. ###
debecho() {
    if [ -n "$DEBUG" ]; then
        echo "DEBUG: $1" >&2
        echo ""
    fi
}

# Check if there is internet connectivity;
# Return 0 if there is, otherwise return 1
check_internet() {
    ping -c 1 google.com &> /dev/null && return 0 || return 1
}

# Trap to clean up on script exit (success or error)
trap cleanup EXIT

OPTSPEC=":dhs:c"
SOURCES=("reddit")
SOURCE="reddit"
while getopts "$OPTSPEC" optchar; do
    case "${optchar}" in
    d)
        echo "DEBUGGING ENABLED!"
        DEBUG=1
        ;;
    h)
        echo "Usage: $0 [OPTION]...
            
Grab the top upvoted wallpaper of the day from r/wallpapers.
            
    -d DEBUGGING 	enable debugging
    -h HELP 		display this help and exit
    -s SOURCE 		specify the source (options: ${SOURCES[*]})
            
Made by Conor C. Peterson (conorpetersondev@gmail.com)
"
        exit 1
        ;;
    s)
        source_name=${OPTARG}
        if [[ " ${SOURCES[*]} " == *" ${source_name} "* ]]; then
            SOURCE=${source_name}
        else
            echo "Invalid source specified. Available options: ${SOURCES[*]}"
            exit 2
        fi
        ;;
    c)
        echo "Cleaning up residual files.."
        rm main.html log.txt wp.html log_wp.html
        exit 3
        ;;
    *)
        echo "usage: $0 [-d] [-h] [-s SOURCE]" >&2
        exit 4
        ;;
    esac
done

# define dbus bus address for notify-send
BUS_ADDRESS="unix:path=/run/user/1000/bus"

# define the connectivity check timeout (in miliseconds)
TIMEOUT_SECONDS=60

# define the wallpaper folder destination path
DESTINATION_PATH="/home/conor/Pictures/wallpapers/"

# define the wallpaper path
SWAY_BACKGROUND_FILE="/home/conor/Pictures/wallpapers/wallpaper"

# Grab SOURCE url
case "${SOURCE}" in
reddit)
    echo "Setting source to reddit.."
    SOURCE_URL="https://www.reddit.com/r/wallpaper/top/"
    ;;
esac

# Notify script is started
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller engaged!' "Grabbing wallpaper from ${SOURCE}" --icon=dialog-information

# Get the current time
start_time=$(date +%s)

# Wait for internet connectivity
echo "Waiting for internet connectivity..."
while ! check_internet; do
    sleep 5

    # Check if the timeout has been reached
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge $TIMEOUT_SECONDS ]; then
        echo "Timeout reached. Internet connection not available after $TIMEOUT_SECONDS seconds."
        exit 1
    fi
done

# Continue with the rest of your script
echo "Internet is now available. Continuing with the script..."

# Download main html
if ! curl -f "$SOURCE_URL" -L -o main.html; then
    notify_error "Failed to download main HTML"
fi

# Save the top post's link to a variable
post_link="$(grep -o '<a href="/r/wallpaper/comments/\w*/\w*' main.html | awk 'BEGIN {FS="/"} NR==1 {print "https://www.reddit.com/r/wallpaper/comments/"$5"/"$6"/"}')"
debecho "Post link: $post_link"

# Download the post's html
if ! curl -f "$post_link" -L -o wp.html; then
    notify_error "Failed to download post HTML"
fi

# Pull image link from html
image_link="$(grep -Eo 'https:/{2}i\.redd\.it/\w+\.[a-z]{3}' wp.html | head -n 1)"
debecho "Image link: $image_link"

# Grab the file name from the image url
filename=$(basename "$image_link")
#extension=$(echo "$filename" | grep -o -E '\.[^./]+$' | grep -o -E '[^.]+$')
debecho "filename: $filename"
#debecho "extension: $extension"

# Set output file path
output_file="$DESTINATION_PATH$filename"
debecho "output_file: $output_file"

# Download the image and save to $output_file
if ! curl -f "$image_link" -o "$output_file"; then
    notify_error "Failed to download image"
fi

# Sway on Wayland requires running swaybg to change background dynamically
# that leaves a running process in the background, which I dislike.
# The way I work around it is by just setting the static file /wallapers/wallpaper
# as a background in sway's config files.
if ! curl -f "$image_link" -o "$SWAY_BACKGROUND_FILE"; then
    notify_error "Failed to set sway background"
fi

# Notify script ended
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller disengaged.' 'Finished grabbing wallpaper.' --icon=dialog-information
