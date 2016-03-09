# A simple flash-based VGA display

The idea of this project is to generate a basic VGA-like signal that a
monitor will display by putting the signal in a flash memory, and then
using counters to run through the address space. Simple, eh?

## VGA signal timing

We have h-sync and v-sync signals, with their respective front and
back porches. The main trick is the find a resolution that fits nicely
into a flash memory, so that the flash memory is a multiple of the
screen size - not the visible screen size, but the screen size with
all the sync bits.

A bit of twiddling gives a 768x480 visible display that is 1024x512
once all the sync etc. is factored in.

## Clocking

Rather than try to engineer something with a ~30MHz clock, I decided
to start with a basic version that can only display "super-wide"
pixels, by running using a 2MHz clock, making each pixel 16
"underlying" pixels wide. Low horizontal resolution in exchange for
making my life a lot easier. This has now been upgraded to a 32MHz
clock being used to produce a 16MHz dot clock.

## VGA levels

H- and V-sync signals are straightforward to produce, as they're
apparently supposed to be TTL. That leaves 6 bits for 3 channels of
colour, or 2 bits per channel. A pair of resistors on each channel
makes the world's simplest DAC, with values chosen to give a 0.7V peak
when terminated by a 75 ohm resistor when both bits are set.

## Test pattern

gen_test.lua generates a simple RGB "checkerboard" displaying the
range of available colours.

gen_rom.lua generates a ROM image given a Gimp .data file (I couldn't
find a nice low-dep Lua image library). It simply takes the top two
bits of each pixel value to generate the colour.

prep_img.lua converts a .data image into another .data image that uses
the 6-bit colour space that the circuit can display. It uses dithering
to improve the generated image. Generating a ROM image from an image
that has been prepared with 'prep_img' should produce a rather better
result.

## Circuit design

The circuit breadboarded so far has three chained 74HC counters
supplying the address to a 29040 flash chip. A 74HC574 latches the
values for the display. (A 74HC574 triggers on the wrong edge to avoid
transients, but it's what I had to hand, and seems to work fine.)

## TODO

 * Look into scan-line doubling
 * Design and manufacture a custom PCB for the project.
