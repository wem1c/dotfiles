#!/bin/sh

## Grimshot: a helper for screenshots within sway
# Requirements:
# - `grim`: screenshot utility for wayland
# - `slurp`: to select an area
# - `swaymsg`: to read properties of current window
# - `wl-copy`: clipboard utility
# - `jq`: json utility to parse swaymsg output
# - `notify-send`: to show notifications

### Modified by https://github.com/wem1c

# Checks if a given command is installed
# and echoes a string based on the results
check() {
  COMMAND=$1
  if command -v "$COMMAND" > /dev/null 2>&1; then
    RESULT="OK"
  else
    RESULT="NOT FOUND"
  fi
  echo "\t$COMMAND: $RESULT"
}

# TODO
die() {
  MSG=${1:-Bye}
  notifyError "Error: $MSG"
  exit 2
}

getTargetDirectory() {
  test -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs && . ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs

  echo ${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME}}
}

# Sends a notification via notify-send
# TODO: Convert to single function
notify() {
  notify-send -t 3000 -a grimshot "$@"
}
# 
notifyOk() {
  [ "$NOTIFY" = "false" ] && return

  TITLE=${2:-"Screenshot"}
  MESSAGE=${1:-"OK"}
  notify "$TITLE" "$MESSAGE"
}
notifyError() {
  if [ $NOTIFY = "true" ]; then
    TITLE=${2:-"Screenshot"}
    MESSAGE=${1:-"Error taking screenshot with grim"}
    notify -u critical "$TITLE" "$MESSAGE"
  else
    echo $1
  fi
}

takeScreenshot() {
  FILE=$1
  GEOM=$2
  OUTPUT=$3
  if [ ! -z "$OUTPUT" ]; then
    grim -o "$OUTPUT" "$FILE" || die "Unable to invoke grim"
  elif [ -z "$GEOM" ]; then
    grim "$FILE" || die "Unable to invoke grim"
  else
    grim -g "$GEOM" "$FILE" || die "Unable to invoke grim"
  fi
}

## MAIN
if [ "$1" = "--notify" ]; then
  NOTIFY=true
  shift 1
else
  NOTIFY=false
fi

ACTION=${1:-usage}
SUBJECT=${2:-screen}
FILE=${3:-$(getTargetDirectory)/grim_"$SUBJECT"_$(date -Iseconds).png}

if [ "$ACTION" != "save" ] && [ "$ACTION" != "copy" ] && [ "$ACTION" != "check" ]; then
  echo "Usage:"
  echo "  grimshot [--notify] {copy|save} [active|screen|output|area|window] [FILE|-]"
  echo "  grimshot check"
  echo "  grimshot usage"
  echo ""
  echo "Commands:"
  echo "  copy: Copy the screenshot data into the clipboard."
  echo "  save: Save the screenshot to a regular file or '-' to pipe to STDOUT."
  echo "  check: Verify if required tools are installed and exit."
  echo "  usage: Show this message and exit."
  echo ""
  echo "Targets:"
  echo "  active: Currently active window."
  echo "  screen: All visible outputs."
  echo "  output: Currently active output."
  echo "  area: Manually select a region."
  echo "  window: Manually select a window."
  exit
fi

if [ "$ACTION" = "check" ] ; then
  echo "Checking if required tools are installed. If something is missing, install it on your system and make it available in PATH..."
  check grim
  check slurp
  check swaymsg
  check wl-copy
  check jq
  check notify-send
  exit
elif [ "$SUBJECT" = "area" ] ; then
  GEOM=$(slurp -d)
  # Check if user exited slurp without selecting the area
  if [ -z "$GEOM" ]; then
    exit 1
  fi
  WHAT="Area"
elif [ "$SUBJECT" = "active" ] ; then
  FOCUSED=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
  GEOM=$(echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
  APP_ID=$(echo "$FOCUSED" | jq -r '.app_id')
  WHAT="$APP_ID window"
elif [ "$SUBJECT" = "screen" ] ; then
  GEOM=""
  WHAT="Screen"
elif [ "$SUBJECT" = "output" ] ; then
  GEOM=""
  OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
  WHAT="$OUTPUT"
elif [ "$SUBJECT" = "window" ] ; then
  GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)
  # Check if user exited slurp without selecting the area
  if [ -z "$GEOM" ]; then
   exit 1
  fi
  WHAT="Window"
else
  die "Unknown subject to take a screen shot from" "$SUBJECT"
fi

if [ "$ACTION" = "copy" ] ; then
  takeScreenshot "$FILE" "$GEOM" "$OUTPUT" || die "grim error"
  wl-copy < $FILE || die "clipboard error"
  notifyOk "$WHAT saved and copied to buffer"
else
  if takeScreenshot "$FILE" "$GEOM" "$OUTPUT"; then
    TITLE="Screenshot of $SUBJECT"
    MESSAGE=$(basename "$FILE")
    notifyOk "$MESSAGE" "$TITLE"
    echo $FILE
  else
    notifyError "Error taking screenshot with grim"
  fi
fi
