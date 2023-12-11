#!/bin/bash

entries="Reboot
Shutdown"

selected=$(printf '%s\n' "$entries" | wofi -S dmenu | awk '{print tolower($1)}')

case $selected in
reboot)
  exec systemctl reboot
  ;;
shutdown)
  exec systemctl poweroff -i
  ;;
esac
