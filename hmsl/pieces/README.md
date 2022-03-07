# Description of Pieces

by Phil Burk

Updated 6/10/87
Updated 1/22/88
Updated 4/26/88
Updated 3/6/2022 - removed non-working pieces

Note that the original version of this file is in README.txt.
It describes some pieces that have not yet been ported to the new HMSL.

A number of short demonstration pieces have been included
to illustrate how to use the various parts of HMSL.
Studied in sequence, they provide a tutorial look
at how to build morph hierarchies, and how to
take advantage of the properties of the various morphs.
You will probably want to print the source code
for all of these.

Most of these demos expect you to have at least two channels
of MIDI starting at channel 1.  The new HMSL's built-in General MIDI
synthesizer should work fine.

---------------------------------------------------

To run these demos, you will need to [install and run HMSL](https://github.com/philburk/hmsl/blob/master/docs/install.md).

Say 'Y' when asked whether to initialize.

You can now compile and run demos. To compile a demo, append ".fth" to the name
and include it. For example, to include DEMO_PLAYER, enter:

    include demo_player.fth
    
The demo will usually tell you what to type in to start the demo.

It is remotely possible for one piece to leave the system
in a state that interferes with the next piece.
If you suspect this, enter BYE, then rerun HMSL as before.

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

5) DEMO_ACTION (not currently working)

Use an ACTION to execute a collection interactively.
Also demonstrates using MIDI Input to trigger sequences
and transform a melody.

6) DEMO_INTERPRETER

Shows how to interpret a shape as something other than
Pitch and Velocity.  You can interpret shapes in any
manner you desire.



-------------

Here are some NEW demos added in 3.1

13) POLYPHASE

Plays four melodies simultaneously in a way that allows
experimentation with "phasing" of melodies of different
lengths.

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
