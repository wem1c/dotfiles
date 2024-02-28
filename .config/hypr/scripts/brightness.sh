#!/usr/bin/env bash
#
# Control screen brightness and notify about the current status.

ICON_INFO="/usr/share/icons/Adwaita/symbolic/status/dialog-information-symbolic.svg"

#######################################
# Get current brigthness.
# Outputs:
#   Writes brightness value to stdout
#######################################
get_brightness() {
	brightness=$(brightnessctl g)
	echo "$brightness"
}

#######################################
# Send notification containing current brightness value.
# Arguments:
#   None
#######################################
notify_user() {
	notify-send -u low -t 2500 -i $ICON_INFO -e "Brightness: $(get_brightness)"
}

#######################################
# Increase brightness by 5% and notify.
# Arguments:
#   None
#######################################
inc_brightness() {
	brightnessctl s +5% && notify_user
}

#######################################
# Decrease brigthness by 5% and notify.
# Arguments:
#   None
#######################################
dec_brightness() {
	brightnessctl s 5%- && notify_user
}

case "$1" in
  "--get")
    get_brightness
    ;;
  "--inc")
    inc_brightness
    ;;
  "--dec")
    dec_brightness
    ;;
  "-h")
    echo "Usage: $0 [OPTION]...
            
Control brightness level.
            
    --get  print current brightness value
    --inc  increase current brightness value by 5% and notify
    --dec  decrease current brightness value by 5% and notify
            
Made by Conor C. Peterson (conorpetersondev@gmail.com)
"
    ;;
  *)
    echo "Usage: $0 [OPTION]"
    ;;
esac
