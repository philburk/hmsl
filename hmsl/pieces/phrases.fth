\ Phrases
\ Plays chords and phrases on various channels.
\ Possibilities can be controlled using check grids.
\
\ First performed Amiga Festival Concert June 17th, 1989
\ This is a stripped down version of a program called AFEST.
\ The original supported FB-01 specific sysex.
\
\ Voice assignments:
\	Chord on 1:3
\	Lead on 2:1
\	Phrases on 3-6:1
\
\ Composer: Phil Burk
\ Copyright 1989 Phil Burk

decimal
include? score{ ht:score_entry
include? ob.fader h:ctrl_fader
include? re-player hp:recent

ANEW TASK-PHRASES
decimal

\ MIDI Control Variables
variable AF-ALL/1
variable AF-CHANNEL
variable AF-MODE
variable AF-PORTATIME
variable AF-IF-SUSTAIN
variable AF-IF-PORTA

\ Define Modes
0 constant AF_PHRASE_MODE
1 constant AF_REST_MODE
2 constant AF_CONVERGE_MODE
3 constant AF_CLOUD_MODE

\ Channel assignments.
1 constant AF_CHORD_CHAN
2 constant AF_LEAD_CHAN
3 constant AF_PHRASES_BASE
variable AF-NUM-PHV    ( number of phrase voices, up to 4 )
: AF_PHRASE_DO ( hi lo -- , loop indices )
	AF_PHRASES_BASE dup 4 + swap
;

false af-all/1 !
af_chord_chan af-channel !
af_phrase_mode af-mode !


: AF.SET.CONTROLS  ( control value -- , set a control for all/1)
	af-all/1 @
	IF af_phrase_do  ( leave chords alone )
		DO i midi.channel!
			2dup midi.control
		LOOP 2drop
	ELSE af-channel @ midi.channel!
		midi.control
	THEN
;

: AF.SUSTAIN ( flag  -- )
	IF 127 ELSE 0 THEN  ( convert flag )
	$ 40 swap af.set.controls
;

: AF.PORTAMENTO ( flag  -- )
	IF 127 ELSE 0 THEN  ( convert flag )
	$ 41 swap af.set.controls
;

: AF.PORTATIME  ( value part -- , set glide rate )
	drop
	dup af-portatime !
	af-all/1 @
	IF af_phrase_do
		DO i midi.channel!
			dup 5 swap midi.control
		LOOP drop
	ELSE af-channel @ midi.channel!
		5 swap midi.control
	THEN
;

: AF.UPDATE.VOICES  ( -- , call when patches change to update )
	af-if-sustain @ af.sustain
	af-if-porta @ af.portamento
	af-portatime @ 0 af.portatime
;

\ ----------------------------------------
OB.JOB JOB-MEASURE
OB.MIDI.INSTRUMENT AF-INS-1

\ Define all the phrases using Score Entry System
score{

64 dup tpw! 2* constant 1MEASURE

\ Harmonious Phrases with D
: PH.DH.0  ( -- )  1/8 D F G A
	1/16 G F G A 1/8 D F G F D F D F 1/4 D
;
: PH.DH.1  ( -- )  1/4 G G 1/8 A G F D 1/4 G REST E F ;
: PH.DH.2  ( -- )  1/2 D G A G ;
: PH.DH.3  ( -- )  1/1 A F ;

\ Harmonious Phrases with E
: OCT- -1 OCTAVE +! ;
: OCT+ 1 OCTAVE +! ;
: PH.EH.0  ( -- )  2 0 DO 1/16 A# G A# G E G E G C# E C# E G E G E LOOP ;
: PH.EH.1  ( -- )  1/8 E REST E E  G REST G G A# 1/16 A# A#
	1/8 G G A# REST G G ;
: PH.EH.2  ( -- )  1/4 E F OCT+  E C# OCT-
	1/8 A# G A# OCT+ C# OCT- A#
	1/4 G E
;
: PH.EH.3  ( -- )  1/2 E G 1/4 E G 1/2 A# 1/1 A# ;

\ Scalar Phrases
: PH.SC.0  ( -- )  1/8 E G F REST E D C# REST
	E G F REST E D C# REST ;
: PH.SC.1  ( -- )  1/6 D E F E F G 1/3 A G F ;
: PH.SC.2  ( -- )  1/4 A D E F 1/8 A G F E F G A REST ;
: PH.SC.3  ( -- )  1/4 D C# D E 1/2 F 1/8 A G F G ;

\ Algorithmic Phrases
: RNOTE ( -- note-index , 1 random note )
	value{ d5 d2 }value wchoose
;

: AF.WALK ( previous -- next )
	2 choose+/- + value{ d2 d5 }value clipto
;

: AF.RLENGTH  ( -- , pick random length )
	5 choose
	CASE
		0 OF 1/16 ENDOF
		1 OF 1/8 ENDOF  \ 8th notes twice as often
		2 OF 1/8 ENDOF
		3 OF 1/4 ENDOF
		4 OF ( leave it the same ) ENDOF
	ENDCASE
;

: PH.R12 ( -- , random notes )
	1/8 8 0 DO rnote note LOOP
	1/4 4 0 DO rnote note LOOP
;

: PH.W12 ( -- , random walk notes )
	value{ d3 }value
	1/4 4 0 DO af.walk dup note LOOP
	1/8 8 0 DO af.walk dup note LOOP
	drop
;

: PH.RG0 ( -- , random notes )
	af-ins-1 instr{
		1/8 8 0 DO rnote note LOOP
		1/4 4 0 DO rnote note LOOP
	}instr
;

: PH.WG0 ( -- , random walk notes in gamut )
	af-ins-1 instr{
	value{ d3 }value
		1/4 4 0 DO af.walk dup note LOOP
		1/8 8 0 DO af.walk dup note LOOP
	drop
	}instr
;

: PH.RGT ( -- , random notes in gamut )
	af-ins-1 instr{
		vtime@ 1measure +
		BEGIN
		af.rlength rnote note
			dup vtime@ <=
		UNTIL drop
	}instr
;

: PH.WGT ( -- , random walk notes in gamut )
	af-ins-1 instr{
		vtime@ 1measure +
	value{ d3 }value
		BEGIN
		af.rlength af.walk dup  note
			over vtime@ <=
		UNTIL 2drop
	}instr
;

: FIB.NOTE  ( n-1 n -- n n+1 , next Fibonacci note )
	tuck + dup 40 + note
;

: PH.FIB ( -- , fibonacci series )
	2 0
	DO  0 1
		1/8 8 0 DO fib.note LOOP
		2drop
	LOOP
;

: PH.SPLIT ( -- , split notes , in opposite directions )
	10 choose 60 +
	1/16 16 0 DO dup i + note dup i - note LOOP
	drop
;

\ ------------------------------------------ Chords
: D.MINOR chord{ D F A }chord ;
: E.DIMINISHED chord{ E G A# }chord ;
: A.MAJOR chord{ C# E A }chord ;
: G.MINOR chord{ D G A# }chord ;

: RAND.TRIAD.G ( -- , play random triad )
	af-ins-1 instr{
		value{ d3 }value
		15 choose +
		chord{ 3 0 DO dup note 2+ LOOP }chord drop
	}instr
;

: RAND.TRIAD.12 ( -- , play random chromatic triad )
	value{ d3 }value
	15 choose +
	chord{ 3 0 DO dup note 4 choose 2+ + LOOP }chord drop
;

: CH.4DN   ( -- )  1/2 4 0 DO d.minor LOOP ;
: CH.4ED   ( -- )  1/2 4 0 DO e.diminished LOOP ;
: CH.4AJ   ( -- )  1/2 4 0 DO a.major LOOP ;
: CH.2GN   ( -- )  1/1 2 0 DO g.minor LOOP ;
: CH.2DN   ( -- )  1/1 2 0 DO d.minor LOOP ;
: CH.4RG   ( -- )  1/2 4 0 DO rand.triad.g LOOP ;
: CH.8RG   ( -- )  1/4 8 0 DO rand.triad.g LOOP ;
: CH.4RC   ( -- )  1/2 4 0 DO rand.triad.12 LOOP ;
: CH.VDE   ( -- )  1/2 d.minor d.minor d.minor
	1/4 d.minor e.diminished ;
: CH.V3E   ( -- )  1/6 3 0 DO e.diminished LOOP
	1/2 3 0 DO e.diminished LOOP ;
: CH.VAJ   ( -- )  1/2 a.major a.major oct+
	1/4 4 0 DO a.major LOOP oct- ;
: CH.VDN   ( -- )  1/1 d.minor 1/4 4 0 DO d.minor LOOP ;

OB.LIST ALL-PHRASES
OB.LIST ALL-CHORDS
OB.LIST PHRASES
OB.LIST CHORDS

variable num-playing

: AF.MAYBE  ( index -- flag , always play at least one )
	1+ af-num-phv @  swap - num-playing @ +
	0 max choose 0=
;

: DO.PHRASES ( job -- , select random phrases )
	drop
	3 octave !
	par{
	af_chord_chan midi.channel!
	af_chord_chan put.channel: af-ins-1
	many: chords ?dup
	IF 1/4  _ff 8 \\
		choose at: chords execute
	THEN
\
	0 num-playing !
	af-num-phv @ 0
	DO  i af.maybe
		IF  1 num-playing +!
			}par{
			i af_phrases_base + dup midi.channel! put.channel: af-ins-1
			4 choose 2 + octave !
\ make phrase dynamics go up or down
			_f 1/4 5 choose+/- //
			many: phrases ?dup
			IF choose at: phrases execute
			THEN
			_mf
		THEN
	LOOP
	}par
;

variable AF-LAST-VTIME

: DO.CONVERGE ( job -- , start notes spread then converge to one )
	drop
	6 1
	DO i midi.channel!
		30 choose 40 + 100 midi.noteon
	LOOP
	1measure 2/ vtime+!
	30 choose 40 +
	6 1
	DO i midi.channel!
		dup 100 midi.noteon
	LOOP
	vtime@ af-last-vtime !
	drop
;

: STOP.CONVERGE  ( job -- , turn off notes )
	af-last-vtime @ 10 + vtime!
	6 1
	DO
		i midi.channel!
		midi.lastoff
	LOOP
;

: DO.CLOUD ( job -- , play notes with spread about center of measure)
	drop
	vtime@
	16 0
	DO 4 choose af_phrases_base + midi.channel!
		0 4 0 DO 1measure choose + LOOP 4/
		over + vtime!  ( random time )
		0 4 0 DO 32 choose + LOOP 4/
		40 +  ( gaussian note ) dup 100 midi.noteon
		20 choose 10 + vtime+! 0 midi.noteoff
	LOOP drop
;

\ Control Grids
\ Turn ON or OFF phrases and Chords
OB.CHECK.GRID  af-cg-chords
OB.CHECK.GRID  af-cg-phrases

OB.SCREEN AFEST-SCREEN

: DO.CHORD.ONOFF  ( value part -- , add or remove chords from OK list )
	at: all-chords swap
	IF  add: chords
	ELSE delete: chords
	THEN
;

: DO.PHRASE.ONOFF  ( value part -- , add or remove phrases )
	at: all-phrases swap
	IF  add: phrases
	ELSE delete: phrases
	THEN
;

: BUILD.ONOFF.P ( -- )
	0 scg.selnt
	4 5 new: af-cg-phrases
	stuff{
		" DH0" " DH1" " DH2" " DH3"
		" EH0" " EH1" " EH2" " EH3"
		" SC0" " SC1" " SC2" " SC3"
		" R12" " W12" " RIG" " WIG"
		" RGT" " WGT" " FIB" " SPL"
	}stuff.text: af-cg-phrases
	'c do.phrase.onoff put.down.function: af-cg-phrases
	" Possible Phrases" put.title: af-cg-phrases
;
: BUILD.ONOFF.C ( -- )
	4 3 new: af-cg-chords
	stuff{
		" 4DN" " 4ED" " 4AJ" " 2GN"
		" 2DN" " 4RG" " 8RG" " 4RC"
		" VDE" " V3E" " VAJ" " VDN"
	}stuff.text: af-cg-chords
	'c do.chord.onoff put.down.function: af-cg-chords
	" Possible Chords" put.title: af-cg-chords
;

\ ---------------------------------------------------------
OB.MENU.GRID AF-CG-MENU

: RAND.PRESETS  ( -- , set 8 random presets )
	2 choose
	IF
		af_phrase_do \ change just phrases
	ELSE
		7 1 \ change all voices
	THEN
	DO i midi.channel! 48 choose 1+ midi.preset
	LOOP
	af.update.voices
;

: CH.PR! ( preset channel --- )
	midi.channel! midi.preset
;

52 value JPV_41
76 value JPV_42
124 value JPV_43
3 value JPV_51
15 value JPV_52
32 value JPV_53

: FIXED.PRESETS1 ( -- , set fixed presets )
	14 1 ch.pr!
		5 2 ch.pr!
	30 3 ch.pr!
	jpv_41 4 ch.pr!
	jpv_51 5 ch.pr!
	af.update.voices
;

: FIXED.PRESETS2 ( -- , set fixed presets )
	14 1 ch.pr!
	30 2 ch.pr!
	10 3 ch.pr!
	jpv_42 4 ch.pr!
	jpv_52 5 ch.pr!
	af.update.voices
;

: FIXED.PRESETS3 ( -- , set fixed presets )
	14 1 ch.pr!
	18 2 ch.pr!
	22 3 ch.pr!
	jpv_43 4 ch.pr!
	jpv_53 5 ch.pr!
	af.update.voices
;

: AF.ALLOFF ( -- )
	7 1 DO i  midi.channel! midi.alloff LOOP
;
: AF.CTRL ( value part -- )
	nip
	CASE
		0 OF af.alloff  ENDOF
		1 OF job-measure do.converge ENDOF
		2 OF rand.presets ENDOF
		3 OF fixed.presets1 ENDOF
		4 OF fixed.presets2 ENDOF
		5 OF fixed.presets3 ENDOF
	ENDCASE
;
: BUILD.CTRL ( -- )
	3 2 new: af-cg-menu
	400 300 put.wh: af-cg-menu
	stuff{
		" AllOff" " Convrg" " RandPr"
		" Fixed1" " Fixed2" " Fixed3"
	}stuff.text: af-cg-menu
	" Actions" put.title: af-cg-menu
	'c af.ctrl put.down.function: af-cg-menu
;

\ ---------------------------------------------------------
OB.CHECK.GRID AF-CG-CHECK

: AF.OPT ( value part -- )
	CASE
		0 OF af-all/1 ! ENDOF
		1 OF dup af-if-sustain ! af.sustain ENDOF
		2 OF dup af-if-porta ! af.portamento ENDOF
	ENDCASE
;
: BUILD.OPT ( -- )
	1 3 new: af-cg-check
	stuff{ " All/1" " Sustain" " Portamento"
	}stuff.text: af-cg-check
	" Options" put.title: af-cg-check
	'c af.opt put.down.function: af-cg-check
;

\ ---------------------------------------------------------
OB.RADIO.GRID AF-CG-MODE

variable AF-OLD-MODE
: AF.MODE ( value part -- )
\ stop converges if that was old mode
	af-old-mode @ 2 =
	IF stop.converge
	THEN
\
	nip dup
	CASE
		0 OF 'c do.phrases 0 put: job-measure ENDOF
		1 OF 'c drop 0 put: job-measure ENDOF
		2 OF 'c do.converge 0 put: job-measure ENDOF
		3 OF 'c do.cloud 0 put: job-measure ENDOF
	ENDCASE
	af-old-mode !
;

: BUILD.MODE ( -- )
	1 4 new: af-cg-mode
	stuff{ " Phrases" " Silent" " Converge" " Cloud"
	}stuff.text: af-cg-mode
	" Mode" put.title: af-cg-mode
	'c af.mode put.down.function: af-cg-mode
;

\ ---------------------------------------------------------
ob.counter AF-CG-CHANNEL

: SYNC.CHANNEL
	af-channel @ 0 put.value: af-cg-channel
;

: AF.CHANGE.CHANNEL  ( value part -- )
	drop dup midi.channel!
	af-channel !
;

: BUILD.CHANNEL ( -- )
	1 -1 put.min: af-cg-channel
	16 -1 put.max: af-cg-channel
\
	" Channel" PUT.title: af-cg-channel
	'c af.change.channel put.down.function: af-cg-channel
	'c sync.channel put.draw.function: af-cg-channel
;

\ ---------------------------------------------------------
ob.counter AF-CG-NUMPV

: SYNC.NUMPV
	af-num-phv @ 0 put.value: af-cg-numpv
;

: AF.CHANGE.NUMPV  ( value part -- )
	drop af-num-phv !
;

: BUILD.NUMPV ( -- )
	4 af-num-phv !
	1 -1 put.min: af-cg-numpv
	4 -1 put.max: af-cg-numpv
\
	" #Phr" PUT.title: af-cg-numpv
	'c af.change.numpv put.down.function: af-cg-numpv
	'c sync.numpv put.draw.function: af-cg-numpv
;

\ Change Voice Parameters
\ Fader to control Portamento Time -------------
ob.fader AF-CG-PTIME

: BUILD.PORTATIME ( -- )
	" Porta-Times" put.title: af-cg-ptime
	0 -1 put.min: af-cg-ptime
	127 -1 put.max: af-cg-ptime
	'c af.portatime put.up.function: af-cg-ptime
;

\ Fader to control Volume -------------
ob.fader AF-CG-volumeC

: SET.volumeC ( value part -- )
	rnow drop
	af_chord_chan midi.channel!
	7 swap midi.control
;

: BUILD.VOLUMEC ( -- )
	" Chords" put.title: af-cg-volumeC
	0 -1 put.min: af-cg-volumeC
	127 -1 put.max: af-cg-volumeC
	127 0 put.value: af-cg-volumeC
	127 0 set.volumeC
	'c set.volumeC put.move.function: af-cg-volumeC
	'c set.volumeC put.up.function: af-cg-volumeC
;

\ Fader to control lead volume -------------
ob.fader AF-CG-volumeL

: SET.volumeL ( value part -- )
	rnow drop
	af_lead_chan midi.channel!
	7 swap midi.control
;

: BUILD.VOLUMEL ( -- )
	" Lead" put.title: af-cg-volumeL
	0 -1 put.min: af-cg-volumeL
	127 -1 put.max: af-cg-volumeL
	127 0 put.value: af-cg-volumeL
	127 0 set.volumeL
	'c set.volumeL put.move.function: af-cg-volumeL
	'c set.volumeL put.up.function: af-cg-volumeL
;

\ Fader to control volumeP -------------
ob.fader AF-CG-volumeP

: SET.volumeP ( value part -- )
	rnow
	drop  af_phrase_do
	DO  i midi.channel!
		7 over midi.control
	LOOP drop
;

: BUILD.VOLUMEP ( -- )
	" Phrases" put.title: af-cg-volumeP
	0 -1 put.min: af-cg-volumeP
	127 -1 put.max: af-cg-volumeP
	127 0 put.value: af-cg-volumeP
	127 0 set.volumeP
	'c set.volumeP put.move.function: af-cg-volumeP
	'c set.volumeP put.up.function: af-cg-volumeP
;

\ ---------------------------------------- Drone
OB.CHECK.GRID af-cg-DRONE

: DRONE.ONOFF ( value part -- )
	1+ midi.channel!
	IF 100
	ELSE 0
	THEN 50 swap midi.noteon
;

: BUILD.DRONE ( -- )
	6 1 new: af-cg-drone
	stuff{ " 1" " 2" " 3" " 4" " 5" " 6"
	}stuff.text: af-cg-drone
	'c drone.onoff put.down.function: af-cg-drone
	" Drones" put.title: af-cg-drone
;

\ ---------------------------------- Build graphics screen
: BUILD.SCREEN ( -- )
	0 scg.selnt
	build.onoff.p
	build.onoff.c
	build.numpv
	build.drone
	build.opt
	build.mode
	build.channel
	build.ctrl
	build.portatime
	build.volumeC
	build.volumeL
	build.volumeP
\ --------------------------------------------------
\ The following code built using control screen editor.
\
	253 372  put.wh: AF-CG-CHORDS
	253 349  put.wh: AF-CG-PHRASES
	160 303  put.wh: AF-CG-DRONE
	399 396  put.wh: AF-CG-MENU
	173 884  put.wh: AF-CG-NUMPV
	166 884  put.wh: AF-CG-CHANNEL
	180 1,583  put.wh: AF-CG-PTIME
	612 396  put.wh: AF-CG-CHECK
	519 396  put.wh: AF-CG-MODE
	180 1,396  put.wh: AF-CG-VOLUMEC
	180 1,396  put.wh: AF-CG-VOLUMEL
	180 1,396  put.wh: AF-CG-VOLUMEP
	20  3 new: AFEST-SCREEN
	AF-CG-CHORDS           100   2,700  add: AFEST-SCREEN
	AF-CG-PHRASES          100     600  add: AFEST-SCREEN
	AF-CG-DRONE          1,729   2,746  add: AFEST-SCREEN
	AF-CG-MENU           2,799     442  add: AFEST-SCREEN
	AF-CG-NUMPV          1,157     628  add: AFEST-SCREEN
	AF-CG-CHANNEL        2,400   1,024  add: AFEST-SCREEN
	AF-CG-PTIME          2,168     326  add: AFEST-SCREEN
	AF-CG-CHECK          1,489     303  add: AFEST-SCREEN
	AF-CG-MODE           1,150   2,234  add: AFEST-SCREEN
	AF-CG-VOLUMEC        2,806   1,769  add: AFEST-SCREEN
	AF-CG-VOLUMEL        3,225   1,745  add: AFEST-SCREEN
	AF-CG-VOLUMEP        3,597   1,745  add: AFEST-SCREEN
\ -----------------------------------------------
	" Phrases by Phil Burk" put.title: afest-screen
	afest-screen default-screen !
;

OB.COLLECTION AF-COL-P
act.parallel: af-col-p

: AFEST.INIT ( -- )
	ns.reset
	1MEASURE   2/ TPW!
\
\ Load CFAs of phrase functions into list of possible phrases
	stuff{ 'c ph.dh.0 'c ph.dh.1 'c ph.dh.2 'c ph.dh.3
		'c ph.eh.0 'c ph.eh.1 'c ph.eh.2 'c ph.eh.3
		'c ph.sc.0 'c ph.sc.1 'c ph.sc.2 'c ph.sc.3
		'c ph.r12 'c ph.w12 'c ph.rg0 'c ph.wg0
		'c ph.rgt 'c ph.wgt 'c ph.fib 'c ph.split
	}stuff: all-phrases
	many: all-phrases new: phrases
\
	stuff{ 'c ch.4dn 'c ch.4ed 'c ch.4aj 'c ch.2gn
		'c ch.2dn 'c ch.4rg 'c ch.8rg 'c ch.4rc
		'c ch.vde 'c ch.v3e 'c ch.vaj 'c ch.vdn
		}stuff: all-chords
	many: all-chords new: chords
\
\ Initialize Instrument for playing in gamut.
	tr-current-key put.gamut: af-ins-1
	tr_key_d tr.harmonic.minor
	0 put.offset: af-ins-1
	af_phrases_base put.channel: af-ins-1
\
	af-ins-1 put.instrument: job-measure  ( to get opened )
	stuff{ 'c do.phrases }stuff: job-measure
	1measure put.duration: job-measure
\
\ Build collection to hold job and player
	re.init
	af_lead_chan put.channel: re-inst
	tr-current-key put.gamut: re-inst
	21 put.offset: re-inst
	stuff{ job-measure re-player }stuff: af-col-p
\
	build.screen
;

: AFEST.TERM
	re.term
	free: all-phrases
	free: all-chords
	free: phrases
	free: chords
\
	freeall: afest-screen
	free: afest-screen
\
	free.hierarchy: af-col-p
	free: af-col-p
	af.alloff
\
\ restore MIDI Parameters
\ delay so voices don't come on
	time@ 1measure + vtime!
	midi.normalize
	0 default-screen !
;

: PLAY.PHRASES
	afest.init
	af-col-p hmsl.play
	afest.term
;

}score

if.forgotten afest.term

." Enter:  PLAY.PHRASES  to hear piece." cr