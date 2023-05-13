#! /usr/bin/bash

## This script grabs the top wallpaper of the day from r/wallpaper!

### Will echo passed parameters only if DEBUG is set to a value. ###
debecho() {
    if [ -n "$DEBUG" ]; then
        echo "$1" >&2
    fi
}

# dbus bus address for notify-send
BUS_ADDRESS="unix:path=/run/user/1000/bus"
SOURCE_URL="https://www.reddit.com/r/wallpaper/top/"
DESTINATION_FILE="/home/conor/Pictures/wallpapers/wallpaper"

# Check if the script is being run with --debug flag
if [ "$1" = "DEBUG=on" ]; then
    echo "DEBUGGING ENABLED!"
    DEBUG=1
fi

# Notify script is started
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller engaged!' "Grabbing today's top wallpaper on r/wallpapers" --icon=dialog-information

# Download main html
wget "$SOURCE_URL" -O main.html -o log.txt

# Save the top post's link to a variable
post_link="$(grep -o '<a href="/r/wallpaper/comments/\w*/\w*' main.html | awk 'BEGIN {FS="/"} NR==1 {print "https://www.reddit.com/r/wallpaper/comments/"$5"/"$6}')"
debecho "Post link: $post_link"

# Download the post's html
wget "$post_link" -O wp.html -o log_wp.html

# Pull image link from html
image_link="$(grep -Eo 'https:/{2}i\.redd\.it/\w+\.[a-z]{3}' wp.html | head -n 1)"
debecho "Image link: $image_link"

# Grab the wallpaper link and download the image itself
wget "$image_link" -O $DESTINATION_FILE

# Cleanup if not debugging
if [ -z "$DEBUG" ]; then
    rm main.html log.txt wp.html log_wp.html
fi

# Notify script ended
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller disengaged.' 'Finished grabbing wallpaper.' --icon=dialog-information
