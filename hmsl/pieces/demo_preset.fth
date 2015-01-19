\ Play a shape that contains a Timbral Dimension.
\ Dimensiions 0,1,2 are Time, Note, and Velocity.
\ Dimension 3 contains a MIDI Preset value.
\
\ Author: Phil Burk 1989

ANEW TASK-DEMO_PRESET  ( mark beginning of file )

\ Declare objects needed by piece.
OB.SHAPE           DPR-SHAPE
OB.PLAYER          DPR-PLAYER
OB.MIDI.INSTRUMENT DPR-INSTR

: SETUP.SHAPE  ( -- , build shape )
	32 4 new: dpr-shape  ( make room )
\  Time Note Velo Preset
	10   5    80    1 add: dpr-shape  ( add data )
	10   7    80   17 add: dpr-shape
	10   8    60   29 add: dpr-shape
	10  10    60   10 add: dpr-shape
	10  12    60    8 add: dpr-shape
;

: INTERP.PRESET.ON  { elmnt# shape instr -- , interpret data }
\ The curly braces indicate the use of local variables.
\ First we grab the data in dimension 3, then
\ call the PRESET: method in the Instrument
	elmnt# 3 shape ed.at: []
	instr preset: []
\
\ Then we play the note using the standard existing Interpreter
	elmnt# shape instr interp.el.on.for
;

\ The initialization and the termination should be clearly
\ separated to simplify testing.
: DPR.INIT ( -- , connect parts together )
	setup.shape
\ Connect Shape and Instrument to Player
	dpr-shape dpr-instr build: dpr-player
\
\ Set ON Interpreter for Instrument
	'c interp.preset.on  put.on.function: dpr-instr
\
\ Set repeat count high to give us time to play with it.
	400000 put.repeat: dpr-player
\
\ Make shape available to Shape Editor
	clear: shape-holder
	dpr-shape add: shape-holder
\ for Cloned demo
	" dpr-shape" put.name: dpr-shape
	dpr-shape standard.dim.names  ( name dism 0,1,2 )
	" Preset" 3 put.dim.name: dpr-shape
;

: DPR.TERM  ( -- , cleanup afterwards )
	free.hierarchy: dpr-player
;

: DPR.PLAY
	dpr-player hmsl.play
;

: DEMO.PRESET  ( -- , play piece )
	dpr.init  ( initialize morphs )
	dpr.play
	dpr.term
;

\ Cleanup automatically if code forgotten.
IF.FORGOTTEN DPR.TERM

cr ." Enter:   DEMO.PRESET" cr  ( remind user how to run it )
