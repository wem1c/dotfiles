#!/bin/sh

# Set device to be toggled
HYPRLAND_DEVICE="elan1300:00-04f3:3087-touchpad"
HYPRLAND_VARIABLE="device:$HYPRLAND_DEVICE:enabled"
ICON_INFO="/usr/share/icons/Adwaita/symbolic/status/dialog-information-symbolic.svg"

# Check if device is currently enabled (1 = enabled, 0 = disabled)
DEVICE="$(hyprctl getoption $HYPRLAND_VARIABLE | grep 'int: 1')"

#######################################
# Send notification containing current brightness value.
# Arguments:
#   Notification message.
#######################################
notify_user() {
	notify-send -u low -t 2500 -i $ICON_INFO -e "$1"
}

if [ -z "$DEVICE" ]; then
	# if the device is disabled, then enable

	# BUG: cannot set fontsize for hyprctl-notify
	# See: https://github.com/hyprwm/Hyprland/issues/4866
  	#hyprctl notify 1 2500 0 "  Enabling touchpad..."
  	notify_user "Enabling touchpad..."
  	
	hyprctl keyword $HYPRLAND_VARIABLE true
else
	# if the device is enabled, then disable

	# BUG: cannot set fontsize for hyprctl-notify
	# See: https://github.com/hyprwm/Hyprland/issues/4866
	#hyprctl notify 1 2500 0 "  Disabling touchpad..."
	notify_user "Disabling touchpad..."
	
	hyprctl keyword $HYPRLAND_VARIABLE false
fi
