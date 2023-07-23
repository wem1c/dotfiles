#! /usr/bin/bash

## This script grabs the top wallpaper of the day from r/wallpaper!

### Will echo passed parameters only if DEBUG is set to a value. ###
debecho() {
    if [ -n "$DEBUG" ]; then
        echo "DEBUG: $1" >&2
        echo ""
    fi
}

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

# dbus bus address for notify-send
BUS_ADDRESS="unix:path=/run/user/1000/bus"
DESTINATION_PATH="/home/conor/Pictures/wallpapers/"
SWAY_BACKGROUND_FILE="/home/conor/Pictures/wallpapers/wallpaper"

# Grab SOURCE url
case "${SOURCE}" in
        reddit)
            echo "Setting source to: reddit.."
            SOURCE_URL="https://www.reddit.com/r/wallpaper/top/"
            ;;
    esac


# Notify script is started
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller engaged!' "Grabbing wallpaper from ${SOURCE}" --icon=dialog-information

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

# Grab the file name from the image url
filename=$(basename "$image_link")
#extension=$(echo "$filename" | grep -o -E '\.[^./]+$' | grep -o -E '[^.]+$')
debecho "filename: $filename"
#debecho "extension: $extension"

# Set output file path
output_file="$DESTINATION_PATH$filename"
debecho "output_file: $output_file"

# Download the image and save to $output_file
wget "$image_link" -O $output_file

# Sway on Wayland requires running swaybg to change background dynamically
# that leaves a running process in the background, which I dislike.
# The way I work around it is by just setting the static file /wallapers/wallpaper
# as a background in sway's config files. 
wget "$image_link" -O $SWAY_BACKGROUND_FILE

# Cleanup if not debugging
if [ -z "$DEBUG" ]; then
    rm main.html log.txt wp.html log_wp.html
fi

# Notify script ended
env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller disengaged.' 'Finished grabbing wallpaper.' --icon=dialog-information
