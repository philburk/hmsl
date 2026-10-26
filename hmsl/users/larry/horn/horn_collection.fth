\ HORN
\  author/composer: Larry Polansky
\ collection for playing whole piece...
anew task-horn_collection

ob.collection HORN-COLL

v: #-horn-channels
16 #-horn-channels !

: INIT.HORN-COLL
	20 new: horn-coll
	#-horn-channels @ 0 DO
		i at: horn-jobs
		add: horn-coll
	LOOP
	vel-changer add: horn-coll
	arp-changer add: horn-coll
;

: RESTART.HORN
	0  measure-# !
\	0 last-index !
	fill.arp-shape
;

: TERM.HORN-COLL
	free: horn-coll
;

: HORN.INIT
    midi_port_external midi-port !
    init.horn  \ shapes
    init.horn.jobs
    init.horn-coll
;

: HORN.TERM
    term.horn-coll
	term.horn.jobs
	term.horn.shapes
	midi.all.channels.off
;

: HORN  ( -- , play Horn piece )
    horn.init
	horn-coll hmsl.play
	horn.term
;

if.forgotten term.horn-coll

cr ." Enter:      HORN     to play the piece." cr
