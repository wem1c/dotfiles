#!/usr/bin/env python3
import os
import sys
import getopt
import subprocess
import requests
from bs4 import BeautifulSoup

# TODO: remove and set BUS_ADDRESS as a global envvar?
# Define dbus bus address for notify-send
BUS_ADDRESS = "unix:path=/run/user/1000/bus"

# Define the wallpaper folder destination path
DESTINATION_PATH = "/home/conor/Pictures/wallpapers/"

# Define the wallpaper path
SWAY_BACKGROUND_FILE = "/home/conor/Pictures/wallpapers/wallpaper"

# Valid script options
OPTSPEC = "dh"

# Available sources
SOURCE_URL = "https://www.reddit.com/r/wallpaper/top/"

# Define the connectivity check timeout (in milliseconds)
TIMEOUT_SECONDS = 60


def notify(message, style="information"):
    """Send a notification using notify-send.

    Keyword arguments:
    message -- notification message
    style -- notification style (default: "information")
    """
    subprocess.run(
        [
            "notify-send",
            "Waller",
            message,
            "--icon=dialog-" + style,
        ]
    )

    if style == "error":
        sys.exit(1)

    return 0


def print_usage():
    """Print usage text."""
    print("Usage: $0 [OPTION]...")
    print()
    print("Grab the top upvoted wallpaper of the day from r/wallpapers.")
    print()
    print("Options:")
    print("  -d 	enable debugging")
    print("  -h 	display this text and exit")
    print()
    print("Made by Conor C. Peterson (conorpetersondev@gmail.com)")


def main(argv):
    debugging = False

    try:
        opts, args = getopt.getopt(argv, OPTSPEC)
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == "-d":
            print("DEBUGGING ENABLED!\n")
            debugging = True
        elif opt == "-h":
            print_usage()
            sys.exit()

    # TODO: implement connectivity check
    # wait_for_internet()

    notify("Grabbing wallpaper...")

    try:
        response = requests.get(SOURCE_URL)
        response.raise_for_status()

    except requests.exceptions.RequestException as error:
        notify(f"Failed to download main HTML: {error}", "error")

    # Extract the top post's link
    soup = BeautifulSoup(response.text, "html.parser")
    post_link = (
        "https://www.reddit.com"
        + soup.find("a", href=lambda x: x and "/r/wallpaper/comments/" in x)["href"]
    )
    if debugging:
        print(f"post_link: {post_link}\n")

    try:
        response = requests.get(post_link)
        response.raise_for_status()

    except requests.exceptions.RequestException as error:
        notify(f"Failed to download post HTML: {error}", "error")

    # Pull image link from html
    soup = BeautifulSoup(response.text, "html.parser")
    image_link = soup.find("a", href=lambda x: x and "https://i.redd.it/" in x)["href"]
    if debugging:
        print(f"Image link: {image_link}")

    filename = os.path.basename(image_link)
    if debugging:
        print(f"filename: {filename}")

    output_file = os.path.join(DESTINATION_PATH, filename)
    if debugging:
        print(f"output_file: {output_file}")

    try:
        response = requests.get(image_link)
        response.raise_for_status()

        with open(output_file, "wb") as output_file:
            output_file.write(response.content)

    except requests.exceptions.RequestException as error:
        notify(f"Failed to download image: {error}", "error")

    # Sway on Wayland requires running swaybg to change background dynamically
    # that leaves a running process in the background, which I dislike.
    # The way I work around it is by just setting the static file /wallpapers/wallpaper
    # as a background in sway's config files.
    with open(SWAY_BACKGROUND_FILE, "wb") as sway_bg_file:
        sway_bg_file.write(response.content)

    # Notify script ended
    notify("Finished grabbing wallpaper.")


if __name__ == "__main__":
    main(sys.argv[1:])
