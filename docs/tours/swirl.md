[Home](../), [Tours](README.md)

# Swirl for Amiga Local Sound

The Amiga computer had 4 audio channels that could play samples or waveforms from memory.
The resolution was only 8 bit but it was quite flexible and allowed composers to
experiment with real-time sound control.

The new implementation of HMSL includes an emulation of the original AMiga hardware
so you can play some of the old Amiga pieces.

## Swirl

Swirl is an interactive instrument that rotates a melody in a pitch-time space.
A note at the beginning of the melody can rotate up to the top middle of the melody and then end up at the end.
The melody will be inverted at this point.

Turn down the volume on your computer and enter:

    include hap:swirl.fth
    swirl

You should see window appear with some control grids and a poly-line.
Turn the volume up carefully. You will hear various notes being played on various samples.

Click on "Forward". You will notice the melody slowly start rotating.
Press "Clear" to see the melody at its current angle.


