#!/bin/bash

entries="Exit
Reboot
Shutdown"

selected=$(printf '%s\n' "$entries" | wofi -S dmenu | awk '{print tolower($1)}')

case $selected in
exit)
  hyprctl dispatch exit
  ;;
reboot)
  exec systemctl reboot
  ;;
shutdown)
  exec systemctl poweroff -i
  ;;
esac
