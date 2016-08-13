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

A bit of twiddling gives a 384x240 visible display that is 512x256
once all the sync etc. is factored in.

## Clocking

A 32MHz clock is used as a dot clock for a 768x480 image at 60 FPS
(1024x512 when sync signals are factored in). The Flash cannot handle
a 32MHz data rate, but we clock it every other cycle and do scan-line
doubling to display a 384x240 image.

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

## PCB

I sent the files in hw/gerbers to http://smart-prototyping.com/, and
they quickly sent me back PCBs which did the job.

### Assembly notes

The PCB is pretty straightforward to assemble (no surface mount!) as
long as you pay attention to the orientations, as I oriented things to
make routing easy, rather than assembly.

There should be enough space for a ZIF for the flash chip, although I
only used an IC socket.

The PCB has been designed to support 8-pin-sized oscillators as well
as 14-pin-sized oscillators. However, I installed the larger size.
Take a careful look at the PCB to see how to install the smaller
crystal if that's what you have. Check that power and ground reach the
appropriate pins.

Note that pin 1 of the power connector is ground, and pin 3 is Vcc.
This is something I wasn't paying attention to when setting up the
schematic (nor did I label it on the silkscreen).

### Animation speed

There are two headers on the board that you can jumper to set the
animation speed. They look like this:

```
 . . .   . . .
   P3      P2
```

The possibilities are:

```
 === .   === . Slow

 === .   . === Medium

 . ===   . === Fast
```

Note that only "medium" displays the 4 frames in the order they are in
memory (i.e. 1 2 3 4 1 2 3 4 ...). In the other two modes, the order
is 1 3 2 4 1 3 2 4 ... (if you're wondering why, it's because the
2-bit counter is bit-reversed). You will need to take this into
account when programming your animations.

## ROM image generation

The 'build.sh' script will generate a nice spinny [Bad Advice
cat](http://knowyourmeme.com/memes/bad-advice-cat) ROM image. If
you're using medium-speed mode, you'll need to pass the 'swap' flag.

I was originally hoping to script up the image wrangling mostly in
Gimp, but it turns out the script-fu support is rubbish. You can't
even [load a raw .data file in a non-interactive
script](https://github.com/marcelteun/GIMP-raw-file-load/blob/5f02e7607b1645d54b11bb9f01d44e362abca2d1/file-raw-load.c#L237).
So, it's just raw data files.

cat.data.gz was generated from cat.png using the Gimp interactively.
Which was me just scrubbing the background off the Bad Advice Cat
image. Minor copyright infringement is probably involved.

If you want to create your own image, I'm sure you can work out how to
do it by looking at build.sh and the lua scripts.
