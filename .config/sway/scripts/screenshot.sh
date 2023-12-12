#!/bin/bash

entries="Active
Screen
Output
Area
Window"

selected=$(printf '%s\n' "$entries" | tofi -c ~/.config/tofi/config_screenshot | awk '{print tolower($1)}')

case $selected in
active)
  ~/.config/scripts/grimshot.sh --notify copy active
  ;;
screen)
  ~/.config/scripts/grimshot.sh --notify copy screen
  ;;
output)
  ~/.config/scripts/grimshot.sh --notify copy output
  ;;
area)
  ~/.config/scripts/grimshot.sh --notify copy area
  ;;
window)
  ~/.config/scripts/grimshot.sh --notify copy window
  ;;
esac
