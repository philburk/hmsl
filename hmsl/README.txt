PHMSL is Portable HMSL
HMSL is the Hierarchical Music Specification Language

HMSL (C) 1986-2006 Phil Burk, Larry Polansky, David Rosenboom
MIDI Synthesizer (C) 2003-2006 Mobileer, Inc
Port to Windows (C) 1996-2006 Phil Burk and Robert Marsanyi

This entire package is PRE-RELEASE and CONFIDENTIAL.
Do NOT distribute without permission of Phil Burk.

To run:
1) Double click:  PHMSL.exe
2) Hit 'y' key to initialize HMSL.

Quick demo to edit a shape.
1) Enter: SHEP
2) Bring HMSL graphics window to front.
3) Click "Insert" button
4) Click on shape to add notes.
5) Click close box to stop editor.

To play a quick MIDI score:
1) Enter: playnow c d e f
2) Enter: playnow 20 0 do 1/16 i choose 50 + note loop

To exit when you are all done:
1) Enter:   BYE

To play a piece.
1) Enter: include pieces/splorp.fth
2) Enter: SPLORP
3) Click on JOBS buttons
4) Play with Complexity fader

Other pieces that have been ported include:
xforms.fth
books.fth
job_jam.fth

To port an HMSL piece to PHMSL.
1) Increase durations. Old duration was about 60 ticks per second. Now it is 689.
2) Change .IF and .THEN to [IF] and [THEN]

