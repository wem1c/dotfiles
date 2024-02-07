#!/usr/bin/env bash
#
# Control default sink volume and notify about the current status.

#######################################
# Get current  volume status via wpctl.
# Outputs:
#   Writes volume status to stdout
#######################################
get_volume() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
	echo "$volume"
}

#######################################
# Send notification containing current volume status.
# Arguments:
#   None
#######################################
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "$(get_volume) %"
}

#######################################
# Increase volume by 2% and notify.
# Arguments:
#   None
#######################################
inc_volume() {
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ && notify_user
}

#######################################
# Decrease volume by 2% and notify.
# Arguments:
#   None
#######################################
dec_volume() {
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && notify_user
}

#######################################
# Toggle volume mute and notify.
# Arguments:
#   None
#######################################
toggle_mute() {
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify_user
}

case "$1" in
  "--get")
    get_volume
    ;;
  "--inc")
    inc_volume
    ;;
  "--dec")
    dec_volume
    ;;
  "--toggle")
    toggle_mute
    ;;
  "-h")
    echo "Usage: $0 [OPTION]...
            
Control default sink volume levels.
            
    --get  print current volume status
    --inc  increase current volume level by 2% and notify
    --dec  decrease current volume level by 2% and notify
    --toggle  toggle volume mute and notify
            
Made by Conor C. Peterson (conorpetersondev@gmail.com)
"
    ;;
  *)
    echo "Usage: $0 [OPTION]"
    ;;
esac
