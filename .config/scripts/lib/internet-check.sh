#!/bin/bash
#
# Define functions to check if the internet is available,
# and to wait for internet connectivity with a timeout.

#######################################
# Check if an internet connection is established.
# Returns:
#   0 if connection is available, 1 otherwise.
#######################################
internet_connected() {
  ping -c 1 google.com &>/dev/null && return 0 || return 1
}

#######################################
# Wait for internet connectivity with a timeout.
# Globals:
#   TIMEOUT_SECONDS
#######################################
wait_for_internet() {
  local start_time
  local current_time
  local elapsed_time

  echo "Waiting for internet connectivity..."

  start_time=$(date +%s)
  while ! internet_connected; do
    sleep 5

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge "$TIMEOUT_SECONDS" ]; then
      echo "Timeout reached. Internet connection not available after $TIMEOUT_SECONDS seconds."
      exit 1
    fi
  done

  echo "Internet is now available."
}
