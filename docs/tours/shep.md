[Home](../)

# Shape Editor

HMSL "Shapes" are multi-dimensional arrays that can hold musical data.
That data can be melodies made of notes, but shapes can also be much more abstract.

HMSL is mostly a programming language, but it also includes a screen for editing shapes. Enter:

    SHEP

You will see a window pop open with a primitive-looking user interface.
(Hey, it was the 80s!)

You will also hear some sound. That is because HMSL is now interpreting
shape-1 as a melody.

## Change Pitches

* In the top-left corner, you will see a Control Grid labeled "Set Mode."
* Click on "Insert," then click in the large box to the right. You will hear more notes being added to the melody.
* Click on "Delete" and try removing some notes.
* Click on "Replace" and try changing the value of some notes.
* Click on "Draw," then drag the mouse across the data. You can use this to quickly enter musical contours.

## Change Timing

Look for a funky up/down widget labeled "Dim." This lets you change which dimension is being edited.
You are currently editing dimension "1," which is being interpreted as pitch.

* Click on the down arrow to go to dimension zero (0).
* Draw on the shape and listen to the effect on the melody.

In this case, dimension zero is being interpreted as note durations in ticks.

## Manipulating the Shape

* Change "Dim" back to one (1) so we can edit pitches.
* Click on "Select" in the "Set Mode" control grid.
* Drag across the middle of the shape to select some notes.
* In the control grid at the bottom left, click on "Reverse." Notice that the selected region is reversed.
* Click on "Scramble" to randomly reorder those notes.

## Generating Random Data

* Click on "Set Y" in the "Set Mode" control grid.
* Click in the selected region just below the notes to draw a horizontal line.
* Click on "Random" in the "Set Mode" control grid.
* Click just above the Y line to randomize the values between the mouse position and the line.
* Click higher up.

When you are done exploring, click the window close box to return to the HMSL terminal.

If you want to learn more about shapes and the Shape Editor, here are the [docs](https://www.softsynth.com/hmsl/docs/original/hman/05-Shapes.pdf).

[Next >> FORTH](forth.md)
