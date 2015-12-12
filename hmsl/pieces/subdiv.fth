\ Select various subdivisions for simultaneous play.
\ A set of shapes, each having a different subdivision of a measure,
\ are created.  A production is written that selects up to 8 of
\ these for simultaneous play.
\
\ Use percussive sounds!!!  (bells, drums, etc.)
\ Uses up to 8 channels of MIDI.
\
\ Author: Phil Burk
\ Original Composition: Phil Corner
\ Copyright 1987
\
\ MOD: PLB 2/2/88  c/dup/divs/ in SD.FILL.SHAPE line 1
\ MOD: PLB 3/26/90 Converted to START/REPEAT function,
\            use SCRAMBLE:
\ MOD: PLB 7/12/90 CLEANUP: COLL-P-1
\ 960613 PLB General MIDI Presets

decimal
ANEW TASK-SUBDIV

8 constant SD_NUM_CHANS
16 constant SD_MAX_DIVS
\ declare as many General MIDI presets as there are DIVS
create SD-PRESETS  10 , 26 , 12 , 14 ,
                    7 , 115 , 109 , 114 ,
                   15 , 11 ,   2 , 12 ,
                   13 , 48 ,   8 , 116 ,

\ Control data
3 4 * 5 * 7 * 11 * constant TICKS/MEASURE
2 constant SD_SCALAR     ( interval between shapes )
50 constant SD_OFFSET

\ List to hold players
OB.OBJLIST  SD-PLAYERS

: SD.FILL.SHAPE { shape divs | tprev -- }
	divs 1 < warning" 0 divisions!"
	divs 2 shape new: []
	0 -> tprev
	divs 1
	DO  i ticks/measure * divs /  ( absolute time of note )
		dup tprev -  ( -- time_now dur )
		divs sd_scalar * shape add: []
		-> tprev
	LOOP
	ticks/measure tprev -  ( remaining duration )
	divs sd_scalar * shape add: []
;

: SD.INIT.UNIT { divs indx | shape player instr -- player , build player }
\ dynamically instantiate necessary morphs
	instantiate ob.shape dup -> shape
	divs sd.fill.shape
	instantiate ob.player -> player
	instantiate ob.midi.instrument -> instr
	shape instr player build: []  ( connect them together )
\
	1 SD_NUM_CHANS instr put.channel.range: []
	indx cells sd-presets + @
		dup .
		put.preset: instr
	sd_offset instr put.offset: []
	player
;

: SD.TERM.UNIT  { player -- , free all morphs }
	0 player get: []  ( get rid of shape )
	dup free: []
	deinstantiate
	player free: []
	player get.instrument: [] deinstantiate
	player deinstantiate
;

: SD.MAKE.PLAYERS  ( max_div -- , make all players )
	dup new: sd-players
	0 DO
		i 1+  i  sd.init.unit
		add: sd-players
	LOOP
;

: SD.KILL.PLAYERS ( -- )
	many: sd-players 0
	DO  i get: sd-players
		sd.term.unit
	LOOP
	free: sd-players
;

: SD.PRINT.SHAPES ( -- )
	many: sd-players 0
	DO i . cr
		i get: sd-players
		0 swap get: []   ( get shape )
		print: []
	LOOP
;

: SD.SIMPLE  ( -- , play simple sequence of divisions )
	12 sd.make.players
	sd-players hmsl.play
	sd.kill.players
;

\ Select multiple parallel tracks.
OB.SHAPE SD-TRACKS-AVAIL  ( available subdivisions )

: SD.SELECT.PLAYER  ( index -- player )
	get: sd-tracks-avail
	get: sd-players
;

: SD.PICKEM  { morph -- , called when coll-p-1 repeats }
\ scramble available tracks
	0   many: sd-tracks-avail 1- 0
		scramble: sd-tracks-avail
\
	morph clear: []
	SD_NUM_CHANS choose 1+ 0
	DO  i sd.select.player
		morph add: []
	LOOP
;

: SD.INIT.MULTI ( -- )
	SD_MAX_DIVS sd.make.players
	SD_NUM_CHANS new: coll-p-1
\
\ Fill shape with available subdivision tracks
	sd_max_divs 1 new: sd-tracks-avail
	sd_max_divs 0
	DO i add: sd-tracks-avail
	LOOP
\
	'c sd.pickem put.start.function: coll-p-1
	'c sd.pickem put.repeat.function: coll-p-1
	20000 put.repeat: coll-p-1
;

: SD.TERM.MULTI ( -- )
	sd.kill.players
	free: sd-tracks-avail
	free: coll-p-1
	default: coll-p-1
;

: SUBDIV  ( -- , perform piece )
	sd.init.multi
	print.hierarchy: coll-p-1
	coll-p-1 hmsl.play
	sd.term.multi
;

cr
." Use percussive sounds!!!  (bells, drums, etc.)" cr
." Uses up to " SD_NUM_CHANS . ." channels of MIDI." cr
." Enter: SUBDIV  to hear piece." cr