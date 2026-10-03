[Home](../), [Tours](README.md)

# Splorp

Splorp is an interactive instrument for controlling multiple voices.

It uses the HMSL Control Grids to create a cross-platform user interface, and it uses HMSL Jobs—flexible, schedulable functions that can perform a wide range of tasks.

    include hp:splorp.fth
    splorp

Click one of the Jobs in the On/Off grid. Each one has a different timbre.
Try moving the faders to hear how the sound changes.

* Pitch — pitch attractor for the jobs
* Duration — maximum note length
* Velocity — MIDI parameter for loudness
* Complexity — harmonic complexity for the intervals: unison, fifth, fourth, major third, sixth, ...

Press "Record," then move some faders.
Now press "Stop," then "Play." It will play back the motion of the faders.

See the [source code for Splorp](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/splorp.fth).
