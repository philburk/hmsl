Description of Demos
by Phil Burk

Updated 6/10/87
Updated 1/22/88
Updated 4/26/88

A number of short demonstration pieces have been included
to illustrate how to use the various parts of HMSL.
Studied in sequence, they provide a tutorial look
at how to build morph hierarchies, and how to
take advantage of the properties of the various morphs.
You will probably want to print the source code
for all of these.

Most of these demos expect you to have at least two channels
of MIDI starting at channel 1.  If you have a
CASIO CZ-101, put it in SOLO mode.  If you
have some thing like an FB-01, put it in MONO8.
Other synthesizers should be in their multitimbral mode.
If you have a single channel synth, place
it in OMNI mode.

---------------------------------------------------

To run these demos, you will need to run HMSL :

    EXECUTE HMSL:ASSIGNS
    RUN HMSL:HMSL4TH

Say 'Y' when asked whether to initialize.
Now enter in the JForth window.

    CD HP:

This will place you in the directory containing the demos.

    INCLUDE filename  ( eg. INCLUDE DEMO_PLAYER )

The demo will usually tell you what to type in to start the demo.
The name is typically the same as the file except the underscore
is replaced by a period.

    eg.  DEMO.PLAYER

It is remotely possible for one piece to leave the system
in a state that interferes with the next piece.
If you suspect this, enter BYE, then rerun HMSL as before.

You may also run out of dictionary space. The dictionary
space can be reclaimed by entering:

    COLD

The demos can be terminated by hitting the close box.

--------------------------------------------

List of Demos

These are meant to be studied in sequence.

1) DEMO_PLAYER

Shows how to build a short predetermined sequence and play it.

2) DEMO_COLLECTION

Run sequences in parallel using a COLLECTION.

3) DEMO_PRODUCTION

Use a PRODUCTION to randomly generate and transfom a melody.

4) DEMO_STRUCTURE

Show how to use a behavior for complex ordering.

5) DEMO_ACTION

Use an ACTION to execute a collection interactively.
Also demonstrates using MIDI Input to trigger sequences
and transform a melody.

6) DEMO_INTERPRETER

Shows how to interpret a shape as something other than
Pitch and Velocity.  You can interpret shapes in any
manner you desire.

---------------

AMIGA Sound Demos

7) DEMO_DRAW

Draw melody played using a sample. You can also edit the
audio waveform.  ZOOM in to see individual waves.

8) DEMO_WAVE

Edit the melody "contour" , the waveform, and the envelope
while they are playing.  Uses AMIGA amplitude modulation
for the envelope.  Uses Equal Tempered Tuning.

-------------

Just for fun...

9) WALKER

Combine sound and graphics (!) into a really simple but
annoying display.

-------------

Here are some NEW demos added in 3.1

10) DEMO_TEMPO

Use vectored TIME@ to achieve a continuously adjustable
tempo.  Controlled from MIDI Input.

11) BOUNCE

An "intelligent instrument" that assigns a melody that
progresses like a bouncing ball to each note of a MIDI
Keyboard. Sounds like a bizarre digital delay.  The
melody can be edited for interesting effects. Requires
a multichannel synth.

12) MASTER_SLAVE

Demonstrates how the MIDI Parser can be used to slave
a computer running HMSL to another computer or sequencer.

13) POLYPHASE

Plays four melodies simultaneously in a way that allows
experimentation with "phasing" of melodies of different
lengths.

14) TRACKER

A fancy arpegiattor that replays the last sixteen notes
played in a repeating sequence.  Uses MIDI parser.

15) WANDER_WAVE

An example of dynamically instantiated objects that
continuously modify a waveform and melody. Uses the
Random Walk class of object.

16) XFORMS

An experiment in algorithmic composition that "develops"
a theme.

17) JOB_JAM

A complicated attempt at coordinating two lead lines
with a rhythmic bass line using algorithmic composition.

18) BOOKS

Play a shape that represents two abstract parameters,
"complexity" and "intensity". This demonstrates
using INTERPRETERS and dynamic instantiation.

19) FELDMAN

Some simple MIDI experiments based on the work of
David Feldman.

20) SUBDIV

An experiment in polyrhythms based on an idea by Phil Corner.

Here's a new demo for version 3.16
21) PLAY_SAMPLE

Loads a dynamic list of instruments with several samples.
The samples can be played from a MIDI keyboard.  Changing
presets on the keyboard will switch samples.

===============================================

I recommend copying some of these demos into your
work directory and modifying them for fun and profit.

    COPY HP:filename  HW:filename
    CD HW:

    RUN editor filename

    INCLUDE filename
