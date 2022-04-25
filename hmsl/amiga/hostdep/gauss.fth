\ Fast Gaussian generator in JForth assembler.
\ Also, a fast random number generator.
\ Gaussian distribution - from an MS-BASIC algorithm via D.R.
\ Sigma determines standard deviation.
\ Xmu determines mean.

\ Nick Didkovsky
\ Adapted from Robert Marsanyi's forth gauss code

anew task-gauss_asm_nd

variable my-rand-seed
here  my-rand-seed !

\ This random number algorithm is fast and "fair".

\ From Cooper/Clancy
\ increment is 13849
\ multiplier is 25173
\ modulus is 65536
\ Seed := ((Multiplier * Seed) + Increment) MOD modulus

\ This random number generator based on Cooper/Clancy "Oh! Pascal!"
\ It appears to give a very even distribution, and it is fast fast fast. ND
\ 10000 calls take 0.45 sec
ASM NEXTRAND.ASM ( -- random#)
 callcfa my-rand-seed
 move.l tos,d0			\ store addr of seed in d0
 move.l $0(org,tos.l),tos	\ fetch seed value
 move.l #25173,d1		\ prepare multiplier
 mulu  d1,tos			\ multiply
 add.l #13849,tos		\ add increment
 and.l #$FFFF,tos		\ modulus
 move.l tos,$0(org,d0.l)	\ update seed
end-code

ob.barray rand-inc

	
\ Fast Gauss.  Notice the random number generator is built into the 
\ code itself. ND
\ Gauss bell looks smooth, and the code is quick.
ASM GAUSS ( sigma xmu -- gauss#)
 	callcfa my-rand-seed	
 	move.l 	tos,a0			\ store addr of seed in a0 ( -- sig xmu ^seed)
 	move.l 	#25173,d1		\ store multiplier in d1
 	move.l 	#$0,d0			\ init loop counter d0
	move.l 	#$0,a1			\ init accumulator a1
 1$: 	addq.l 	#$1,d0			\ increment loop counter
     	move.l 	a0,tos			\ get seed addr
     	move.l 	$0(org,tos.l),tos	\ fetch seed
     	mulu   	d1,tos			\ multiply seed
	add.l   #13849,tos		\ add increment
     	and.l  	#$FFFF,tos		\ modulus seed
 	move.l 	tos,$0(org,a0.l)	\ update seed value
 	asr.l  	#$6,tos			\ 1024 choose
	add.l	tos,a1			\ update accumulator
	cmpi.l	#$8,d0			\ test loop exit
  	blt	1$
	move.l	a1,tos			\ ( -- sigma xmu total)
	move.l	#4096,d1
	neg.l	d1
	add.l	d1,tos
	move.l 	$4(dsp),d0
	muls 	d0,tos
	asr.l	#5,tos
	asr.l	#5,tos
	add.l	(dsp)+,tos
  	addq.l	#$4,dsp		
end-code


\ ********************************* TESTS ***************************

\ Visually test distribution of random number generator...
: test.nextrand.asm ( -- )
cr
." This simple test uses an array 0-65535 and runs a loop which" cr
." generates 32767 random numbers also in the range 0-65535" cr
." The array keeps track of which numbers were generated and" cr
." how many times they were generated" cr
." The routine prints out the contents of the array for visual" cr
." inspection of any 'obvious' patterns" cr
." Simple-minded, statistically invalid perhaps, but it shed enough" cr
." light on an algorithm I WAS using to cause me to throw it out" cr
." and use this one instead" cr
." wait about 30 seconds..." flushemit
  65536 new: rand-inc
  65536 0 do
	0 i to: rand-inc
  loop
  32767 0 do
	nextrand.asm dup at: rand-inc 1+ swap to: rand-inc
  loop
." Hit any key to stop" cr
." Look for repeating patterns or anything else suspicious..." cr
  65536 0 do
	i at: rand-inc . 
	i 31 and 31 = IF cr THEN
	?terminal if leave then
  loop
;

ob.shape gauss-bell

\ Visually test shape of Gauss bell
: test.bell ( -- )
  ." wait..." flushemit
  150 1 new: gauss-bell
  150 0 do
	0 add: gauss-bell
  loop
  20000 0 do
	16 64 gauss dup 0 ed.at: gauss-bell 1+ swap 0 ed.to: gauss-bell
  loop
  clear: shape-holder
  gauss-bell add: shape-holder
  ." done, now type hmsl and inspect gauss bell" cr
;

\ Test speed of Gauss generator...
\ benchmarks:
\ 12.18 seconds with original gauss (coded in pure forth)		
\ 2.98 seconds with this asm version.
: bench.gauss ( -- )
  10000 0 do
	16 64 gauss drop
  loop
;

