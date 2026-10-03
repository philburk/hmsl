[Docs Home](.)

# Quick Tour

If you haven't already, [download and install HMSL](install.md).

The new HMSL provides a built-in General MIDI synthesizer from Mobileer.
To test MIDI output, enter:

    midi.seqout

You should hear a few notes play. 

To launch an interactive editor, enter:

    shep
    
The Shape Editor window should appear and you should hear a repeated melody. Click the "Draw" option.
Draw on the graph to extend the melody.
Close the graphics window to stop the editor.

HMSL include a text based score entry system. Try typing the code below. OR use the copy icon at the right of the code and then Paste the code into HMSL.

    score{
    playnow  c4  a  g  e

To play notes with different durations using a Forth DO LOOP enter:

    playnow 4 0 do  1/4 c4 a  1/8 g e loop

HMSL includes [several](https://github.com/philburk/hmsl/tree/master/hmsl/pieces) old algorithmic compositions. Most of them are designed to work with a General MIDI Synthesizer.
XFORMS, written in 1989, is a piece that copies a theme and then ornaments it. 
To compile and run it, enter:

    include hp:xforms.fth
    xforms

Click up arrow in "Select Shape" widget to see "sh-devel". You can watch the theme being copied and modified.

Back in the 1980's, if you wanted to make computer music you had to write software.
Here is the [source code for xforms.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/xforms.fth).

Click [here for more guided tours](tours/).

Read more tutorials and docs at <http://www.softsynth.com/hmsl/>
