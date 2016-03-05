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
