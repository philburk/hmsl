[Home](../), [Tours](README.md)

# Swirl for Amiga Local Sound - 1987

The Amiga computer had four audio channels that could play samples or waveforms from memory.
The resolution was only 8-bit,
but it was quite flexible and allowed composers to
experiment with real-time sound control.

The new implementation of HMSL includes an emulation of the original Amiga audio hardware,
so you can play some of the classic Amiga pieces.

## Swirl

Swirl is an interactive instrument that rotates a melody through pitch-time space.
A note at the beginning of the melody can rotate up to the top middle and then end up at the end.
At that point, the melody is inverted.

Turn down the volume on your computer and enter:

    include hap:swirl.fth
    swirl

You should see a window appear with some control grids and a polyline.
Turn the volume back up carefully. You will hear various notes being played on different samples.

Click on "Forward." You will notice the melody slowly start rotating.
Press "Clear" to see the melody at its current angle.

See the [source code for Swirl](https://github.com/philburk/hmsl/blob/master/hmsl/amiga/pieces/swirl.fth).

[Next >> Hierarchies](morph.md)
