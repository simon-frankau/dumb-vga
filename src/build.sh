#!/bin/sh

set -e

# TODO: Assumes the existence of out[1234].data files, which I'll be
# building more scripting to generate...

# Dither the source files for the limited bit depth we can display
for IMAGE in out?.data
do
  lua prep_img.lua -i $IMAGE -o dithered_$IMAGE
done

# Convert from raw files to raster images that can be fed as a VGA
# signal.
for IMAGE in dithered_out?.data
do
  lua gen_rom.lua -i $IMAGE -o $IMAGE.bin
done

# Place the images back to back to create the final ROM
cat dithered_out?.data.bin > spin.bin
