\ b'rey'sheet tests

anew task-b_tests

\ tests one voice from amiga
: TEST.LOCAL.ARRAY ( -- )
	9 0 DO
		0 da.channel!
		da.start
		I at: local.pitch.array
		scaled.da.freq! key drop
	LOOP
;


: TEST.F.ARRAY ( -- )
	1 midi.channel!
	9 0 DO 
		f.lastoff
		i at: f.pitch.array
		i at: ff.pitch.array
		120 f.noteon
		key drop 
	LOOP
;

: TEST.ARRAYS
	1 midi.channel!
	0 da.channel!
	da.start
	9 0 DO
		f.lastoff
		i at: f.pitch.array
		i at: ff.pitch.array
		120 f.noteon
		i at: local.pitch.array
		scaled.da.freq!
		key drop 
	LOOP
;

\ just lets the user tune the fundamental of local sound to the fb
: TUNE.LOCAL->FB
	0 da.channel!
	f_a ff_a 120 f.noteon
	20 0 DO
		l_a i 10 - + 
		dup .
		scaled.da.freq!
		key drop
	LOOP
;

		
