#!/bin/sh

# Set device to be toggled
HYPRLAND_DEVICE="elan1300:00-04f3:3087-touchpad"
HYPRLAND_VARIABLE="device:$HYPRLAND_DEVICE:enabled"

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

# Check if device is currently enabled (1 = enabled, 0 = disabled)
DEVICE="$(hyprctl getoption $HYPRLAND_VARIABLE | grep 'int: 1')"

if [ -z "$DEVICE" ]; then
	# if the device is disabled, then enable
  	hyprctl notify 1 2500 0 "  Enabling touchpad..."
	hyprctl keyword $HYPRLAND_VARIABLE true
else
	# if the device is enabled, then disable
	hyprctl notify 1 2500 0 "  Disabling touchpad..."
	hyprctl keyword $HYPRLAND_VARIABLE false
fi
