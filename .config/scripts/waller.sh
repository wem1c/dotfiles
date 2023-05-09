#! /usr/bin/bash

## This script grabs the top wallpaper of the day from r/wallpaper!
# dbus bus address for notify-send
BUS_ADDRESS="unix:path=/run/user/1000/bus"

# Notify script is started
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Script started!' 'Executing wallpaper.sh.' --icon=dialog-information

# SOURCE: r/wallpaper sorted by top of the day
SOURCE_URL="https://www.reddit.com/r/wallpaper/top/"
DESTINATION_FILE="/home/conor/Pictures/wallpapers/wallpaper"

# Download main html
wget "$SOURCE_URL" -O main.html -o log.txt

# Save the top post's link to a variable
post_link="$(grep -o '<a href="/r/wallpaper/comments/\w*/\w*' main.html | awk 'BEGIN {FS="/"} NR==1 {print "https://www.reddit.com/r/wallpaper/comments/"$5"/"$6}')"

# Download the post's html
wget "$post_link" -O wp.html -o log_wp.html

# Pull image link from html and sanitize it
image_link="$(grep '<a href="https://i\.redd\.it/\w\+\.\w\+' wp.html -o | awk 'BEGIN {FS="\""} {print $2}')"

# Grab the wallpaper link and download the image itself
wget $image_link -O $DESTINATION_FILE

# Cleanup
rm main.html log.txt wp.html log_wp.html

# Notify script ended
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Script finished.' 'Wallpaper.sh finished execution.' --icon=dialog-information
