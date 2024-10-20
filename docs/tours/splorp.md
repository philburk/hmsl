[Home](../), [Tours](README.md)

# Splorp

Splorp is an interactive instrument that controls multiple voices.

It uses the HMSL Control Grids to create a cross-platform user interface.

It uses HMSL Jobs which are flexible schedulable functions that can perform arbitrary tasks.

    include hp:splorp.fth
    splorp

Click on one of the Jobs in the On/Off grid. Each one has a different timbre.
Try moving the faders to see what effect it has.

* Pitch - pitch attractor for the jobs
* Duration - maxmimum note length
* Velocity - MIDI parameter for loudness
* Complexity - harmonic complexity for the intervals: unison, 5th, 4th, major 3rd, 6th, ...

Press "Record" then move some faders.
Now press "Stop" then "Play. It will play back the movement of the faders.

See the [source code for splorp](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/splorp.fth).
