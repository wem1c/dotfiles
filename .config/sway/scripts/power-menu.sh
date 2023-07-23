#!/bin/bash

entries="Logout
Reboot
Shutdown"

selected=$(printf '%s\n' "$entries" | tofi -c ~/.config/tofi/config_powermenu | awk '{print tolower($1)}')

case $selected in
logout)
  swaymsg exit
  ;;
reboot)
  exec systemctl reboot
  ;;
shutdown)
  exec systemctl poweroff -i
  ;;
esac
