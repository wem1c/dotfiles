#!/bin/bash

entries="Logout Reboot Shutdown"

selected=$(printf '%s\n' $entries | wofi --conf=$HOME/.config/wofi/config_power --style=$HOME/.config/wofi/style_widget.css | awk '{print tolower($1)}')

case $selected in
  logout)
    swaymsg exit;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
