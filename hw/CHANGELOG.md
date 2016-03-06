# v0

Very first circuit I created. Low frequency (2MHz), has a few problems
(black stripes between the wide "pixels").

Note that the R and B channels are swapped around compared to what I
actually built (and thus what I wrote scripts for), as it's equivalent
and makes the schematic a lot easier to draw.

# v0.1

I added a 74574 latch to the output, so that the transients from the
output of the Flash aren't sent over the VGA lines, which resulted in
black stripes on the screen.

74574 = no stripes. Hurrah!

# v0.2

Switched from 2MHz oscillator to 16MHz oscillator, making the pixels
8x narrower. A 32MHz oscillator would give square pixels, but the
29040 takes 55ns to read, so that would be too fast.

Oscilloscope output looked good, but video didn't display. The
oscillator's output didn't look like a great square wave, but putting
an inverter or two on the 74754 latch's clock line made the display
work. It's not totally clear to me if this was because it helped
square up the wave, or perhaps because it fixed up a clock phase issue
- I need to investigate more.

By attaching the high address line to the highest bit of the counter,
we can create a simple animation with 2 frames.

# v0.3

Moved the inverter to directly after the oscillator. The display
works. This suggests that it's the signal shape, not phase issues
between different chips, that causes the problem. It seems only the
latch is annoyed by the shape of the oscillator output being
insufficiently square.

# v0.4

This revision is an optimisation, removing the inverter. As the
problem was feeding the oscillator output directly into the latch, I
removed the oscillator and did it another way: Replace the 16MHz
oscillator with a 32MHz oscillator, move all the address pins along to
get the same frequency counting, and use the lowest bit of the counter
as the clock for the latch. It seems to do the trick.

A downside is that the animation now only runs at twice the speed as
before (a bit manic), but it's a trade-off I'm willing to take to
eliminate a whole IC from a small design.
