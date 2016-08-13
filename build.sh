#!/bin/sh
#
# Script to generate the ROM contents needed to display the image on
# the hardware.
#

set -e

mkdir -p out
cd out

# Generate the "sunburst"
lua ../tools/gen_img.lua

# Swap ordering of frames if you're running in "medium" speed
# animation mode.
if [[ "$1" == "swap" ]]
then
  mv out2.data saved.data
  mv out3.data out2.data
  mv saved.data out3.data
fi

# Extract the compressed cat image data
gunzip -c ../data/cat.data.gz > cat.data

# Overlay the cat
for IMAGE in out?.data
do
  lua ../tools/compose.lua -1 cat.data -2 $IMAGE -o overlay_$IMAGE
done

# Dither the source files for the limited bit depth we can display
for IMAGE in overlay_out?.data
do
  lua ../tools/prep_img.lua -i $IMAGE -o dithered_$IMAGE
done

# Convert from raw files to raster images that can be fed as a VGA
# signal.
for IMAGE in dithered_overlay_out?.data
do
  lua ../tools/gen_rom.lua -i $IMAGE -o $IMAGE.bin
done

# Place the images back to back to create the final ROM
cat dithered_overlay_out?.data.bin > spin.bin
