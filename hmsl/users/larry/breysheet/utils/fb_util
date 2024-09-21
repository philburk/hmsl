\ fb01 utilities
\ system exclusive implementation
\ as of 7/12/87 only pitch stuff is working, parameter stuff
\ needs to be tested

\ note: polansky adapted some of burk's tools for this. all
\ bug responsibility = polansky
\ polansky 6/87

anew task-fb_util

\ general variables for fbo1
v: f-note#
v: f-fraction

hex

\ constants -- Instrument definition block
0 k: f_#notes 	1 k: f_mchannel
4 k: f_vbank	5 k: f_v#	6 k: f_detune
7 k: f_oct	8 k: f_output	9 k: f_pan
a k: f_lenable	d k: f_m/p

\ constants --  Parameters
10 k: f_lspeed	11 k: f_amd	12 k: f_pmd
13 k: f_f-wave	14 k: f_lldenable	
15 k: f_lsync	16 k: f_ams	17 k: f_pms

decimal

\ System Exclusive Event

\ primitives  -- these next routines all read variables

: F.ID
	$ 43 midi.xmit 
;

: F.SUBSTATUS 
	$ 75 midi.xmit $ 70 midi.xmit 
;

: F.START.EVENTS 
	sysex f.id f.substatus midi.flush false midi-if-opt ! 
;

: F.STOP.EVENTS 
	endsysex midi.flush
;

\ the following routines work fine, 7/20/87
: F.NOTEON ( note fraction  velocity --- )
    f.start.events
    3 xdup  
    drop f-fraction ! f-note# ! \ store for f.lastoff
    $ 10 midi.cvm+3D
    f.stop.events
;

: F.NOTEOFF  ( note fraction -- )
	f.start.events
        $ 00 midi.cvm+2D
	f.stop.events
;

: F.LASTOFF
	f.start.events
	f-note# @ f-fraction @  f.noteoff
	f.stop.events
;

\ the next routine is still in testing 
: F.PARAMETER ( par# value -- )
	$ 70 midi.cvm+2d
;

\ following also untested right now
: F.KILL  ( turns off hanging events )
	128 0 DO 
		128 0 DO j i  f.noteoff 5 msec 
		LOOP 
	loop
;

\ these are test routines

v: midi-dur

300 MIDI-DUR !

: MIDI.HIT  ( -- , Sound note )
    56 100 midi.noteon    midi-dur @ msec
    midi.lastoff    midi-dur @ msec
;

: FB.HIT16 ( -- , Sound 16 channels )
    16 0
    DO  i 1+ dup . cr midi.channel!
        midi.hit
        ?terminal IF leave THEN
    LOOP
;

: FB.TEST1  ( -- , random melody in semitone range)
    100 0
    DO  100 choose 52 over 120 f.noteon
        50 msec
        52 swap f.noteoff
        50 msec
    LOOP
;

