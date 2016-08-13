#!/bin/sh

set -e

# Generate the "sunburst"
lua gen_img.lua

# Extract the compressed cat image data
gunzip -kf cat.data.gz

# Overlay the cat
for IMAGE in out?.data
do
  lua compose.lua -1 cat.data -2 $IMAGE -o overlay_$IMAGE
done

# Dither the source files for the limited bit depth we can display
for IMAGE in overlay_out?.data
do
  lua prep_img.lua -i $IMAGE -o dithered_$IMAGE
done

# Convert from raw files to raster images that can be fed as a VGA
# signal.
for IMAGE in dithered_overlay_out?.data
do
  lua gen_rom.lua -i $IMAGE -o $IMAGE.bin
done

# Place the images back to back to create the final ROM
cat dithered_overlay_out?.data.bin > spin.bin
