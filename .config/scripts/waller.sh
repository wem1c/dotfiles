#! /usr/bin/bash
#
# Download the top wallpaper of the day from r/wallpaper.

# define dbus bus address for notify-send
readonly BUS_ADDRESS="unix:path=/run/user/1000/bus"

# define the wallpaper folder destination path
readonly DESTINATION_PATH="/home/conor/Pictures/wallpapers/"

# define the wallpaper path
readonly SWAY_BACKGROUND_FILE="/home/conor/Pictures/wallpapers/wallpaper"

# valid script options
readonly OPTSPEC=":dhs:c"

# available sources
readonly SOURCES=("reddit")

# define the connectivity check timeout (in miliseconds)
export TIMEOUT_SECONDS=60

source lib/internet-check.sh

#######################################
# Send a notification containing the given error message
# Arguments:
#   Error message
#######################################
err() {
  local message="$1"
  env DBUS_SESSION_BUS_ADDRESS="$BUS_ADDRESS" notify-send 'Waller encountered an error!' "$message" --icon=dialog-error
  exit 1
}

#######################################
# Print if debugging is enabled.
# Arguments:
#   Message to be printed.
#######################################
debecho() {
  if [ -n "$DEBUG" ]; then
    echo "DEBUG: $1" >&2
    echo ""
  fi
}

cleanup() {
  rm main.html post.html "$output_file"
}

main() {
  local source="reddit"

  # Run cleanup() on script exit
  trap cleanup EXIT

  # Parse command line options
  while getopts "$OPTSPEC" optchar; do
    case "${optchar}" in
      d)
        echo "DEBUGGING ENABLED!"
        readonly DEBUG=1
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
        local source_name=${OPTARG}
        if [[ " ${SOURCES[*]} " == *" ${source_name} "* ]]; then
          source=${source_name}
        else
          echo "Invalid source specified. Available options: ${SOURCES[*]}"
          exit 2
        fi
        ;;
      *)
        echo "usage: $0 [-d] [-h] [-s SOURCE]" >&2
        exit 4
        ;;
    esac
  done

  # Grab SOURCE url
  case "${source}" in
    reddit)
      echo "Setting source to reddit.."
      readonly SOURCE_URL="https://www.reddit.com/r/wallpaper/top/"
      ;;
  esac

  # Notify script is started
  env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller engaged!' "Grabbing wallpaper from ${source}" --icon=dialog-information

  wait_for_internet

  if ! curl -f "$SOURCE_URL" -L -o main.html; then
    err "Failed to download main HTML"
  fi

  # Extract the top post's link to post_link
  local post_link
  post_link="$(grep -o '<a href="/r/wallpaper/comments/\w*/\w*' main.html \
    | awk 'BEGIN {FS="/"} NR==1 {print "https://www.reddit.com/r/wallpaper/comments/"$5"/"$6"/"}')"
  debecho "Post link: $post_link"

  if ! curl -f "$post_link" -L -o post.html; then
    err "Failed to download post HTML"
  fi

  # Pull image link from html
  image_link="$(grep -Eo 'https:/{2}i\.redd\.it/\w+\.[a-z]{3}' post.html | head -n 1)"
  debecho "Image link: $image_link"

  filename=$(basename "$image_link")
  debecho "filename: $filename"

  output_file="$DESTINATION_PATH$filename"
  debecho "output_file: $output_file"

  if ! curl -f "$image_link" -o "$output_file"; then
    err "Failed to download image"
  fi

  # Sway on Wayland requires running swaybg to change background dynamically
  # that leaves a running process in the background, which I dislike.
  # The way I work around it is by just setting the static file /wallapers/wallpaper
  # as a background in sway's config files.
  if ! curl -f "$image_link" -o "$SWAY_BACKGROUND_FILE"; then
    err "Failed to set sway background"
  fi

  # Notify script ended
  env DBUS_SESSION_BUS_ADDRESS=$BUS_ADDRESS notify-send 'Waller disengaged.' 'Finished grabbing wallpaper.' --icon=dialog-information
}

main "@"
