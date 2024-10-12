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

    playnow 4 0 do  1/4 c4  1/8 a g  1/4 e loop

HMSL includes [several](https://github.com/philburk/hmsl/tree/master/hmsl/pieces) old algorithmic compositions. Most of them are designed to work with a General MIDI Synthesizer.
[XFORMS](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/xforms.fth) is a piece that copies a theme and then ornaments it. 
To compile and run it, enter:

    include pieces/xforms.fth
    xforms

Click up arrow in "Select Shape" widget to see "sh-devel". You can watch the theme be copied and modified.

Click [here for more guided tours](tours/).

Read more tutorials and docs at <http://www.softsynth.com/hmsl/>
