#!/bin/bash

echo "Now installing the script and launch agent to have some nice wallpapers"
echo "With some security software you might get an alert that a launch agent is installed. That's the point but feel free to check the source :)"
echo "Press enter to continue, or ^C to abort"
read

# Directory where the files will be
WD="$HOME/Library/Application Support/io.qsd.wallpaperd"

# Not required but why not
umask 77

# The Program path must be absolute...
echo "Writing launchd plist: $HOME/Library/LaunchAgents/io.qsd.wallpaperd.plist"
sed -e "s:HOMEDIR:$HOME:" io.qsd.wallpaperd.plist > "$HOME/Library/LaunchAgents/io.qsd.wallpaperd.plist" || exit 1

# Copy files
echo "Writing files to $WD"
mkdir -vp "$WD" || exit 1
cp -v wallpaperd.bash "$WD" || exit 1
cp -v transform.bash "$WD" || exit 1

# Load launch agent
echo "Loading launch agent"
launchctl load "$HOME/Library/LaunchAgents/io.qsd.wallpaperd.plist" || exit 1

echo "If everything went well, you have a new wallpaper..."
