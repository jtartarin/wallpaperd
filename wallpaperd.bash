#!/bin/bash

# This script runs from launchd
# see https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html
# see ~/Library/LaunchAgents/io.qsd.wallpaperd.plist

# Edits in this file or in transform.bash do not need any reload to be applied
# View logs in Console.app, search for "wallpaperd"

# Some configuration

# set DO_TRANSFORM to true if you want to run the transform userscript. false to skip it.
DO_TRANSFORM=false

# set REFRESH_TIME to the number of minutes a wallpaper should last. 0 to change it every 30 seconds (StartInterval in plist)
REFRESH_TIME=120

# set UNSPLASH_URL to the correct size and tags that you wish
HOUR=$(date +%H)
case "$HOUR" in
  21|22|23|00|01|02|03|04|05)
    UNSPLASH_URL="https://source.unsplash.com/featured/2560x1600?california+night"
    ;;
  06|07|08|09)
    UNSPLASH_URL="https://source.unsplash.com/featured/2560x1600?california+sunrise"
    ;;
  18|19|20)
    UNSPLASH_URL="https://source.unsplash.com/featured/2560x1600?california+sunset"
    ;;
  *)
    UNSPLASH_URL="https://source.unsplash.com/featured/2560x1600?california"
    ;;
esac

# Working directory
WD="./Library/Application Support/io.qsd.wallpaperd"

# Used for interval check and manual refresh
CHECKFILE="last_one.delete_to_force_refresh"

cd ~
mkdir -p "$WD"
cd "$WD"

function log {
  logger $0 "$@"
}

function logexit {
  logger $0 "$@"
  exit 1
}

function set_wp {
  log "setting wallpaper in osascript"
  	osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "'"$(pwd -P)/$1"'"'  
  	#osascript -e 'display notification "You have a new wallpaper :)" with title "wallpaperd"'
}

# First run or force refresh
if [ ! -e "$CHECKFILE" ]
then
    log "creating checkfile"
    touch -t 201701010000 "$CHECKFILE"
fi

# Check interval to run
if test $(find "$CHECKFILE" -mmin +$REFRESH_TIME)
then
  mkdir -p dl wp
  
  TMP=$(date +%s).jpg
  
  log "fetching $UNSPLASH_URL"
  curl -sL --url "$UNSPLASH_URL" -o dl/$TMP

  SHASUM=$(shasum dl/$TMP | awk -F' ' '{print $1}')
  
  LATEST=$SHASUM.orig.jpg
  LATEST_TRANSFORMED=$SHASUM.transformed.png
  mv -n dl/$TMP dl/$LATEST
  
  # Test is made on actual file and not on return code (sometimes errors return HTML stuff and don't fail the curl)  
  if [ "$(file -bI dl/$LATEST)" = "image/jpeg; charset=binary" ]
  then
    	log "fetched wallpaper $LATEST"
    	ln -fs dl/$LATEST latest.jpg
    	
    	if [ "$DO_TRANSFORM" = true ]
    	then
      	log "transform.bash dl/$LATEST wp/$LATEST_TRANSFORMED"
      bash transform.bash dl/$LATEST wp/$LATEST_TRANSFORMED || logexit "transform failed, returned $?"
      	ln -fs wp/$LATEST_TRANSFORMED latest.transformed.png      
      set_wp wp/$LATEST_TRANSFORMED
    else
      log "no transform"
      set_wp dl/$LATEST
    fi

    touch "$CHECKFILE"
    log "all done"
    	exit 0
  fi
  
  log "didn't work properly :("
  exit 1

else
  # Wallpaper is not old enough
  #log "too soon to change wallpaper"
  exit 0
fi

