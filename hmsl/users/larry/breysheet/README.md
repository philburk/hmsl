# B'rey'sheet by Larry Polansky

* Composed by Larry Polansky
* Programmed by Larry Polansky (and Phil Burk)
* Restored by Phil Burk and Andrew Smith
* Originally sung by Jody Diamond
* On "The Theory of Impossible Melody" (ART 1004, 1989), track released December 24, 1989
  
## Summary

B'rey'sheet is for solo voice and live interactive computer. It is one of the Cantillation Studies,
a set of pieces based on computer-aided melodic transformations of the traditional Hebrew
tropes and melodies used for singing the Torah.

More details at a recording at https://artifactrecordings.bandcamp.com/track/breysheet-in-the-beginning-cantillation-study-1

Technical notes: B'rey'sheet was first realized and premiered on the prototype of HMSL (VI.0)
in 1984 at the Center for Contemporary Music at Mills College.
It was later adapted for an Amiga computer running HMSL.
The two-computer version on this recording was rewritten in HMSL V4.0 with the assistance of Phil Burk. 

## Hardware Setup

This piece requires:

* One (or tqwo) computers running the new HMSL with the Amiga local sound emulation, or an Amiga
* IVL PitchRider for pitch tracking the singer
* Yamaha FB-01 for microtonal sound generation
* Roland DEP-5 for reverb and other processing

## How to Run

Compile the code.

    include users/assigns.fth
    include hulp:b_load.ftht

Run the master code.

    b.master
    
## Code Notes
