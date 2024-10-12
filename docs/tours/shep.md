[Home](../)

# Shape Editor

HMSL "Shapes" are a multi-dimensional array that can contain musical data.
The data can be melodies made of notes. But shapes can also be much more abstract.

HMSL is mostly a programming language. But it also has a screen for editing shapes. Enter:

    SHEP

You will see a window pop open with a primitive looking user interface.
(Hey, it was the 80's!) 

You will also hear some sound. That is because HMSL is now interpreting 
shape-1 as a melody.

## Change Pitches

* On the top left you will see a Control Grid labelled "Set Mode".
* Click on "Insert" and then click in the large box to the right. You will hear more notes being added to the melody.
* Click on "Delete" and try removing some notes.
* Click on "Replace" and try to change the value of some notes.
* Click on "Draw" and then drag the mouse across the data. You can use this to quickly enter musical contours.

## Change Timing

Look for a funky up/down widget labelled "Dim". This let's you change which dimension is being edited.
You are currently editing dimension "1", which is being interpreted as pitch.

* Click on the down arrow to go to dimension zero (0).
* Draw on the shape and listen to the effect on the melody.

In this case, dimension zero is being interpreted as note durations in ticks.

## Manipulating the Shape

* Change "Dim" back to one (1) so we can edit pitches.
* Click on "Select" in the "Set Mode" control grid.
* Drag across the middle of the shape to select some notes.
* In the Control Grid at the bottom left, click on "Reverse". Notice that the selected region is reversed.
* Click on "Scramble" to randomly reorder those notes.

## Generating Random Data

* Click on "Set Y" in the "Set Mode" control grid.
* Click in the selected region just below the notes to draw a horizontal line.
* Click on "Random" in the "Set Mode" control grid.
* Click just above the Y line to randomize the values between the mouse position and the line.
* Click higher up.

When you are done exploring, click the window close box to get back to the HMSL terminal.
