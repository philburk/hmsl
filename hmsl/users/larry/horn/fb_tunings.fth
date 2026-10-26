\ HORN
\ composer: Larry Polansky
\ 2/3/90

anew task-fb_tunings

\ Tuning file, sets up SHAPES with FBO1 tunings in them

v: Fundamental ( set this to decide what key the whole piece is in )
v: cents-offset

34 k: Bb
Bb fundamental ! ( set key to Bb )

( SHAPES which contain harmonic series in the proper order... )
ob.shape 1-SHAPE
ob.shape 5-SHAPE
ob.shape 3-SHAPE

ob.shape 1-harm-SHAPE
ob.shape 5-harm-SHAPE
ob.shape 3-harm-SHAPE

( SHAPE which contains resultant 19 note arpeggio at any given time... )
ob.shape ARP-SHAPE

( SHAPE which contains order of entry of harmonics... )
ob.shape ORDER-SHAPE
ob.shape HARM-ORDER-SHAPE

: INIT.HORN.SHAPES
	17 4 new: 1-SHAPE ( harm# n f cents )
		1 put.data: 1-shape
	17 4 new: 5-SHAPE
		5 put.data: 5-shape
	17 4 new: 3-SHAPE
		3 put.data: 3-shape
	17 4 new: 1-HARM-SHAPE ( harm# n f cents )
		1 put.data: 1-harm-shape
	17 4 new: 5-HARM-SHAPE
		5 put.data: 5-harm-shape
	17 4 new: 3-HARM-SHAPE
		3 put.data: 3-harm-shape
	19 7 new: ARP-SHAPE ( series# n f velocity precedence harm# cents )
	17 1 new: ORDER-SHAPE
	17 1 new: HARM-ORDER-SHAPE
;



: FILL.ORDER-SHAPES
	17 13 11 14 7 15 10 5 9 12 6 3 16 8 4 2 1 
	17 0 DO
		add: order-shape
		i 1+ add: harm-order-shape
	LOOP
;


\ ===============================================================
\ ================================================================

\ Added in 2029-10-24 by Phil Burk. I could not find a definition.
: FB.CENTS->NF ( cents -- note fraction )
    100 /mod swap
;

\ SHAPES which contain tunings and FBO1 values for harmonic series'
: RATIO->NF ( num den -- note fraction )
	ratio->cents ( -- cents )
	fundamental @ 100 * 
	cents-offset @ + ( cents value of fundamental )
	+ ( -- new cents value )
	dup ( -- cents cents )
	fb.cents->nf ( -- cents n f )
;

: FILL.1-SHAPES
	17 set.many: 1-shape
	17 set.many: 1-harm-shape
	17 0 DO
	( fill "Psaltery" order 1-shape )
		i at: order-shape ( -- # )
		dup ( -- # # )
		1 ratio->nf ( --  # cents n f )
		rot 	   ( --  # n f cents  )
		i put: 1-SHAPE
	( fill shape in harmonic series order )
		i at: harm-order-shape
		dup 
		1 ratio->nf rot
		i put: 1-harm-shape
	LOOP
	" Harm# " 0 put.dim.name: 1-harm-shape
	" FBO1 Value " 1 put.dim.name: 1-harm-shape
	" FBO1 Fraction " 2 put.dim.name: 1-harm-shape
	" Cents " 3 put.dim.name: 1-harm-shape
	" Harm# " 0 put.dim.name: 1-shape
	" FBO1 Value " 1 put.dim.name: 1-shape
	" FBO1 Fraction " 2 put.dim.name: 1-shape
	" Cents " 3 put.dim.name: 1-shape
;

: FILL.3-SHAPEs
	fundamental @
	fundamental @ 7 + fundamental !
	2 cents-offset !
	17 set.many: 3-shape
	17 set.many: 3-harm-shape
	17 0 DO
		i at: order-shape ( -- # )
		dup 
		1 ratio->nf ( --  cents n f )
		rot 	   ( --  n f cents  )
		i put: 3-SHAPE
	( fill shape in harmonic series order )
		i at: harm-order-shape
		dup 
		1 ratio->nf rot
		i put: 3-harm-shape
	LOOP
	fundamental !
	" Harm# " 0 put.dim.name: 3-harm-shape
	" FBO1 Value " 1 put.dim.name: 3-harm-shape
	" FBO1 Fraction " 2 put.dim.name: 3-harm-shape
	" Cents " 3 put.dim.name: 3-harm-shape
	" Harm# " 0 put.dim.name: 3-shape
	" FBO1 Value " 1 put.dim.name: 3-shape
	" FBO1 Fraction " 2 put.dim.name: 3-shape
	" Cents " 3 put.dim.name: 3-shape
;

: FILL.5-SHAPEs
	fundamental @
	fundamental @ 3 + fundamental !
	86 cents-offset !
	17 set.many: 5-shape
	17 set.many: 5-harm-shape
	17 0 DO
		i at: order-shape ( -- # )
		dup 
		1 ratio->nf ( --  cents n f )
		rot 	   ( --  n f cents  )
		i put: 5-SHAPE
	( fill shape in harmonic series order )
		i at: harm-order-shape
		dup 
		1 ratio->nf rot
		i put: 5-harm-shape
	LOOP
	" Harm# " 0 put.dim.name: 5-harm-shape
	" FBO1 Value " 1 put.dim.name: 5-harm-shape
	" FBO1 Fraction " 2 put.dim.name: 5-harm-shape
	" Cents " 3 put.dim.name: 5-harm-shape
	" Harm# " 0 put.dim.name: 5-shape
	" FBO1 Value " 1 put.dim.name: 5-shape
	" FBO1 Fraction " 2 put.dim.name: 5-shape
	" Cents " 3 put.dim.name: 5-shape
	fundamental !
;

: FILL.ARP-SHAPE
	" Series# " 0 put.dim.name: arp-shape
	" FBO1 Value " 1 put.dim.name: arp-shape
	" FBO1 Fraction " 2 put.dim.name: arp-shape
	" Velocity " 3 put.dim.name: arp-shape
	" Precedence " 4 put.dim.name: arp-shape
	" Harm# " 5 put.dim.name: arp-shape
	" Cents " 6 put.dim.name: arp-shape
	19 set.many: arp-shape
	17 0 DO
		1 i 0 ed.to: arp-shape ( set series to 1 )
		i 1 ed.at: 1-harm-shape i 1 ed.to: arp-shape
		i 2 ed.at: 1-harm-shape i 2 ed.to: arp-shape
		0 i 3 ed.to: arp-shape ( fill initial velocities with 0 )
		0 i 4 ed.to: arp-shape ( initial precedences )
		i i 5 ed.to: arp-shape ( harmonic series order to start )
		i 3 ed.at: 1-harm-shape i 6 ed.to: arp-shape ( put in cents )
	LOOP
;

: FILL.TUNING.SHAPES
	fill.order-shapes
	fill.1-shapes
	fill.3-shapes
	fill.5-shapes
	fill.arp-shape
	1-shape add: shape-holder
	3-shape add: shape-holder
	5-shape add: shape-holder
	1-harm-shape add: shape-holder
	3-harm-shape add: shape-holder
	5-harm-shape add: shape-holder	
	order-shape add: shape-holder
	harm-order-shape add: shape-holder
	arp-shape add: shape-holder
;

: INIT.HORN
	init.horn.shapes
	fill.tuning.shapes
	cr cr cr
	tab ." (first type FB.START.EVENTS) " cr
	." (and then 58 0 is the F that Chris needs for tuning) "
	cr cr
;

: TERM.HORN.SHAPES
	free: 1-SHAPE ( harm# n f cents )
	free: 5-SHAPE
	free: 3-SHAPE
	free: ARP-SHAPE 
	free: ORDER-SHAPE
	free: HARM-ORDER-SHAPE
	clear: shape-holder
;

if.forgotten term.horn.shapes
