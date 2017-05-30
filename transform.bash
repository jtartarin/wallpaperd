#!/bin/bash

# bash transform.bash orig_file transformed_file
# Do something with orig_file ($1) and write it in transformed_file ($2)

# This is an example using ImageMagick
# see http://brewformulas.org/Imagemagick to install ImageMagick
# see https://www.imagemagick.org/Usage/layers/ for documentation/examples

# This is my current sticker setup
# see https://www.stickermule.com/marketplace
# always buy the physical version :)

# Yes you have to figure out the pixel coordinates yourself and it's a pain
# but ImageMagick rocks and you don't need a fancy UI to do that.

/usr/local/bin/convert $1 \
  \( -page +140+180 -rotate -15 -background transparent stickers/you-had-me-at-ehlo.png \) \
  -page +550+240 stickers/coreos.png \
  -page +250+250 stickers/docker.png \
  \( -page +1600+165 -rotate -19 -background transparent stickers/billionaire.png \) \
  -page +1800+160 stickers/there-is-no-cloud.png \
  -page +2100+1242 stickers/lets-encrypt.png \
  -page +180+1040 stickers/zombies-love-brains.png \
  -page +140+1342 stickers/php7.png \
  -page +980+1342 stickers/eff.jpg \
  -flatten $2

exit $?
