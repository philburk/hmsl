\ WAVEFORMS provides various samples for use with digital sampler
\ audio devices like the AMIGA
\
\ Author: Phil Burk
\ Copyright 1987 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 11/8/86 Use OB.SHAPE as <SUPER for editing!!
\ MOD: PLB 11/21/86 Use AR.SIGNED.C@ for proper range.
\ MOD: PLB 12/9/86 Moved setting of above to NEW:
\ MOD: PLB 12/15/86 Use 0= instead of NOT for file open check.
\ MOD: PLB 12/17/86 Added stock waveforms.
\ MOD: PLB 3/13/87  Adjusted DMA catch for samples.
\ MOD: PLB 9/9/87 Use blocks for drawing for speed.
\ MOD: PLB 9/15/87 Set limits to -128 to 127
\ MOD: PLB 9/21/87 Use Coded MIN.MAX.BYTES for speed.
\ MOD: PLB 10/26/87 Converted to use IFF sample files.
\ MOD: PLB 11/16/87 Sped up REVERSE: and fixed START:
\ MOD: PLB 8/11/89 Set type to MEMF_CHIP for EXTEND:

MRESET LOAD:
ANEW TASK-WAVEFORMS

\ Declare methods.
METHOD LOAD:
METHOD SAVE:
METHOD FINISH:
METHOD USE:
METHOD TEST:
METHOD CALC.OCTAVE:
METHOD CALC.OCTAVE.REPEAT:
METHOD PERIOD>OCTAVE:
METHOD PUT.PERIOD:
METHOD GET.PERIOD:
METHOD SET.PERIOD:
METHOD PUT.OCTAVE:
METHOD GET.OCTAVE:
METHOD PUT.#OCTAVES:
METHOD GET.#OCTAVES:
METHOD PUT.#ONESHOT:
METHOD GET.#ONESHOT:
METHOD PUT.#REPEAT:
METHOD GET.#REPEAT:
METHOD EXTRACT.OCTAVE:
METHOD PUT.OPTIMAL.PERIOD:
METHOD GET.OPTIMAL.PERIOD:

V: ADDR-OF-ZERO
V: WA-BUCKET    ( Place to read words and longs. )
decimal

:CLASS OB.WAVEFORM <SUPER OB.SHAPE
    IV.LONG IV-MS-FILEID
    IV.LONG IV-OPTIMAL-PERIOD
    IV.LONG IV-WA-PERIOD  ( current period )
    IV.LONG IV-WA-OCTAVE  ( current octave )
\ These Instance Variables are the same as a Voice8Header structure.
\ Do not insert any more variables in between them!
    IV.LONG  iv-OneShotHiSamples
    IV.LONG  iv-RepeatHiSamples
    IV.LONG  iv-SamplesPerHiCycle
    IV.SHORT iv-SamplesPerSec
    IV.BYTE  iv-ctOctave
    IV.BYTE  iv-sCompression
    IV.LONG  iv-volume
\ End of Voice8Header ---------

\ The AMIGA uses signed audio data -128<->127, therefore:
: AR.SIGNED.C@  ( index -- data , sign extend byte )
    ar.c@ b->s
;
\ We don't need to worry about AR.C! since it masks high bits.

:M INIT: ( -- )
    init: super
    0 iv=> iv-ms-fileid
    1 set.width: self    ( byte wide )
    300 iv=> iv-optimal-period
;M

:M NEW:  ( #bytes -- , Allocate in AMIGA chip memory. )
    MEMF_CHIP mm-type !  ( Set for mm.alloc )
    1 new: super   ( single dimension )
\ Install signed fetch word, no range checking on AT:
    'c ar.signed.c@  iv=> iv-ar-cfa-at  ( %M )
\ Set sample value limits.
    -128 127 0 put.dim.limits: self
;M

:M EXTEND:  ( many -- )
    MEMF_CHIP mm-type !  ( use CHIP RAM )
    extend: super
;M

: WA.READ ( addr #bytes -- , read bytes sequentially from file )
    iv-ms-fileid  -rot
    dup >r fread r> = NOT
    IF " WA.READ" " All bytes not read!" er_return er.report
    THEN
;

: WA.READ.WORD ( -- word , read word from file )
    wa-bucket 2 wa.read
    wa-bucket w@
;

: WA.READ.LONG ( -- long , read longword from file )
    wa-bucket 4 wa.read
    wa-bucket @
;

: MS.READ.CHUNK  ( -- size , read a chunk )
    wa.read.long dup ." CODE = " code>$ count type cr
    wa.read.long  even-up  >r
    CASE
        'VHDR' OF iv&> iv-oneshothisamples r@ wa.read
               ENDOF
        'NAME' OF pad r@ wa.read pad r@ type cr
               ENDOF
        'ATAK' OF pad r@ wa.read ." ATAK not supported!" cr
               ENDOF
        'AUTH' OF pad r@ wa.read pad r@ type cr
               ENDOF
        '(C)'  OF pad r@ wa.read pad r@ type cr
               ENDOF
        'BODY' OF r@ new: self
                  data.addr: self r@ wa.read
                  r@ set.many: self
               ENDOF
               ." Unrecognized CODE" dup . cr
               iv-ms-fileid r@ offset_current fseek drop
    ENDCASE
    r>
;
            
: MS.READ.8SVX  ( form_size -- , read 8SVX FORM )
    BEGIN
        dup 0>
    WHILE
        ms.read.chunk - 8 -
    REPEAT
    drop
;

: WA.FIX.SAMPLE ( -- , fix internal variables )
    iv-ctoctave 0=
    IF ." # Octaves set to 1!" cr 1 iv=> iv-ctoctave
    THEN
    iv-samplespersec 0=
    IF ." Sample Rate set to 12000!" cr
        12000 iv=> iv-samplespersec
    THEN
;

:M LOAD: ( $name -- , load a sample from a file )
    $fopen ?dup 0=      ( %H open file )
    IF
        " LOAD: OB.WAVEFORM" " Couldn't open file!"
        er_fatal ob.report.error
    ELSE cr
        iv=> iv-ms-fileid
        wa.read.long 'FORM' = NOT
        IF
            iv-ms-fileid  fclose
            name: self
            " LOAD: OB.WAVEFORM" " Not an IFF FORM file!."
            er_fatal er.report
        ELSE
            wa.read.long ( form size )
            wa.read.long '8SVX' =
            IF cell- ms.read.8svx
            ELSE iv-ms-fileid  fclose
                " LOAD: OB.WAVEFORM" " Not an 8SVX FORM"
                er_fatal er.report
            THEN
        THEN
        iv-ms-fileid  fclose
        wa.fix.sample
    THEN
    iv-samplespersec 1 da.fl->p 2* iv=> iv-optimal-period
;M

\ Writing to file.
: WA.WRITE ( addr #bytes -- , WRITE bytes sequentially TO file )
    iv-ms-fileid  -rot
    fwrite drop    
;

: WA.WRITE.WORD ( word --, write word to file )
    wa-bucket w!
    wa-bucket 2 wa.write
;
: WA.WRITE.LONG ( long -- , write longword to file )
    wa-bucket !
    wa-bucket 4 wa.write
;

: WA.WRITE.8SVX ( -- )
\ Write header.
    'VHDR' wa.write.long
    20 wa.write.long  ( Vheader size )
    iv&> iv-oneshothisamples 20 wa.write
\ Write sample data.
    'BODY' wa.write.long
    many: self wa.write.long
    data.addr: self many: self wa.write
;

: WA.TOP.MANY ( -- #/top.octave )
    iv-oneshothisamples iv-repeathisamples +
;

: WA.CHECK.LENGTHS ( -- true_if_bad )
\ Calc how many bytes should be there.
    wa.top.many 1 iv-ctoctave ashift 1- *
    many: self - 0= 0=
;

: WA.WRITE.WAVEFORM ( -- )
    'FORM' wa.write.long
    0      wa.write.long  ( come back later and fix )
    '8SVX' wa.write.long
    wa.write.8svx
    iv-ms-fileid 4 offset_beginning fseek  ( -- size )
    8 - dup ." Form Size = " . cr wa.write.long
;

:M SAVE: ( 0$name -- , load a sample to a file )
    wa.fix.sample
    wa.check.lengths
    IF drop cr name: self ."  has a mismatch in lengths!"
       ." Fix or use UPDATE:" cr
    ELSE
        new $fopen ?dup 0=      ( %H open file )
        IF
            name: self
            " SAVE: OB.SAMPLE" " Couldn't open file!"
            er_fatal er.report
        ELSE
            iv=> iv-ms-fileid  ( save file id )
            wa.write.waveform
            iv-ms-fileid  fclose
        THEN
    THEN
;M

:M UPDATE: ( -- , adjust internal variables )
    wa.check.lengths
    IF iv-ctoctave 1 >
        IF ." Multiple Octaves!" cr
	   ." Update manually using PUT.#ONESHOT: and PUT.#REPEAT:" cr
	ELSE many: self iv=> iv-repeathisamples
            0 iv=> iv-oneshothisamples
        THEN
    THEN
;M

\ ----------------------------------------------------

:M CALC.OCTAVE: ( octave_number -- offset count )
    1 swap ashift wa.top.many dup>r * dup r> - swap
;M

:M CALC.OCTAVE.REPEAT: ( octave_number -- repeat_offset repeat_count )
    dup 1+ calc.octave: self drop  ( -- octave offset[1+] )
    1 rot ashift iv-repeathisamples * dup>r - r>
;M

:M PERIOD>OCTAVE: ( period -- period' octave )
    iv-ctoctave 1 >
\    IF iv-ctoctave 1- swap iv-ctoctave 0
    IF iv-ctoctave 1- tuck 0
        DO  ( -- octave period )
            dup iv-optimal-period <
            IF nip i swap leave
            THEN
            2/
        LOOP swap
    ELSE 0
    THEN
;M

:M PUT.#OCTAVES: ( #octaves -- )
    iv=> iv-ctoctave
;M
:M GET.#OCTAVES: ( -- #octaves )
    iv-ctoctave
;M
:M PUT.OPTIMAL.PERIOD: ( period -- )
    iv=> iv-optimal-period
;M
:M GET.OPTIMAL.PERIOD: ( -- period )
    iv-optimal-period
;M
:M PUT.#ONESHOT: ( #oneshot -- )
    iv=> iv-oneshothisamples
;M
:M GET.#ONESHOT: ( -- #oneshot )
    iv-oneshothisamples
;M
:M PUT.#REPEAT: ( #repeat -- )
    iv=> iv-repeathisamples
;M
:M GET.#REPEAT: ( -- #repeat )
    iv-repeathisamples
;M

:M PUT.PERIOD: ( period -- )
    dup da.period!
    iv=> iv-wa-period
;M
:M GET.PERIOD: ( -- period)
    iv-wa-period
;M

:M PUT.OCTAVE: ( octave -- )
    iv=> iv-wa-octave
;M
:M GET.OCTAVE: ( -- octave )
    iv-wa-octave
;M

:M SET.PERIOD: ( period -- , set virtual period )
    period>octave: self
    iv=> iv-wa-octave
    put.period: self
;M

:M USE:  ( -- , use the sample by setting it up on an audio channel )
      data.addr: self many: self da.sample!
;M

:M FINISH: ( -- , finish waveform )
    da.stop
;M

:M START: ( -- )
      use: self
      da.start
;M

:M EXTRACT.OCTAVE: ( octave_number waveform -- )
    >r  ( waveform )
    dup zzel1 !  ( octave_number )
    calc.octave: self ( -- offset count )
    dup r@ new: []  ( make room )
    dup r@ set.many: []
    1 r@ put.#octaves: []
    dup zzel1 @ calc.octave.repeat: self
      ( -- offset count count offset_repeat count_repeat )
    nip dup r@ put.#repeat: []
      ( -- offset count count count_repeat )
    - r@ put.#oneshot: []  ( -- offset count )
    0 swap r@ copy: self
    rdrop
;M

:M TEST: ( -- , test playing the waveform )
    iv-samplespersec 1 da.fl->p 124 max da.period!
    start: self
    cr ." Hit <CR> to stop!" key drop
    finish: self
;M

:M PRINT: ( -- )
    cr
    ."   # / One Shot = " iv-oneshothisamples . cr 
    ."   # / Repeat   = " iv-repeathisamples . cr
    ."   # / cycle    = " iv-samplesperhicycle . cr
    ."   Sample Rate  = " iv-samplespersec . cr
    ."   #of Octaves  = " iv-ctoctave . cr
    print: super
;M

;CLASS

\ Special coded REVERSE for speed.
: REVERSE.BYTES  ( addr1 addr2 -- , reverse intervening bytes)
   [ hex
     2247  w, \  MOVE.L  TOS,A1                 
     D3CC  w, \  ADDA.L  ORG,A1                 
     D3FC w, 0000 w, 0001 w, \  ADDA.L  #$1,A1                 
     205E  w, \  MOVE.L  (DSP)+,A0              
     D1CC  w, \  ADDA.L  ORG,A0                 
     1010  w, \  MOVE.B  (A0),D0                
     1221  w, \  MOVE.B  -(A1),D1               
     1280  w, \  MOVE.B  D0,(A1)                
     10C1  w, \  MOVE.B  D1,(A0)+               
     B3C8  w, \  CMPA.L  A0,A1                  
     6CF4  w, \  BGE.S   $1B3DE                 
     2E1E  w, \  MOVE.L  (DSP)+,TOS
   decimal ]        
;

\ Low level word for finding MIN and MAX of a set of bytes.
: MIN.MAX.BYTES ( min max addr count -- min max )
   [ hex
     2F03  w,    \  MOVE.L  D3,-(RP)               
     7000  w,    \  MOVEQ.L #$0,D0                 
     2200  w,    \  MOVE.L  D0,D1                  
     205E  w,    \  MOVE.L  (DSP)+,A0              
     221E  w,    \  MOVE.L  (DSP)+,D1              
     201E  w,    \  MOVE.L  (DSP)+,D0              
     D1CC  w,    \  ADDA.L  ORG,A0                 
     1618  w,    \  1$: MOVE.B  (A0)+,D3               
     B601  w,    \  CMP.B   D1,D3                  
     6F04  w,    \  BLE.S   $1B7B2                 
     1203  w,    \  MOVE.B  D3,D1                  
     6006  w,    \  BRA.S   $1B7B8                 
     B600  w,    \  CMP.B   D0,D3                  
     6C02  w,    \  BGE.S   $1B7B8                 
     1003  w,    \  MOVE.B  D3,D0                  
     51CF  w,  -12 w,  \ DBF   D7,1$       
     4880  w,    \  EXT.W   D0                     
     48C0  w,    \  EXT.L   D0                     
     2D00  w,    \  MOVE.L  D0,-(DSP)              
     2E01  w,    \  MOVE.L  D1,TOS                 
     261F  w,    \  MOVE.L  (RP)+,D3               
  decimal ]
;


\ Audio sample class.
METHOD TEST.PART:
METHOD PUT.#BLOCKS:
METHOD GET.#BLOCKS:
METHOD DECIMATE:

:CLASS OB.SAMPLE <SUPER OB.WAVEFORM
    IV.LONG IV-SM-#BLOCKS

:M INIT:
    init: super
    256 iv=> iv-sm-#blocks
;M

:M FINISH: ( -- , finish waveform )
     addr-of-zero @ 2  da.sample!  ( silence it at end )
;M

:M USE: ( -- )
    iv-wa-octave calc.octave: self swap data.addr: self +  swap
    da.sample!
;M

:M START:  ( -- )
      da.period@ 1 da.period!  ( complete waveform )
      da.stop
      dup -2 ashift 0 DO LOOP ( delay to catch value %M )
      da.period!
      use: self
      da.start
      iv-repeathisamples
      IF iv-wa-octave calc.octave.repeat: self swap data.addr: self + swap
      ELSE addr-of-zero @ 2
      THEN
      da.sample!  ( silence it at end )
;M

:M UPDATE: ( -- , adjust internal variables )
    wa.check.lengths
    IF iv-ctoctave 1 >
        IF ." Multiple Octaves!" cr
	   ." Update manually using PUT.#ONESHOT: and PUT.#REPEAT:" cr
	ELSE many: self iv=> iv-oneshothisamples
            0 iv=> iv-repeathisamples
        THEN
    THEN
;M

:M TEST: ( -- , test playing the waveform )
    cr 200 15 0
    DO  dup ." Period = " . cr
        dup set.period: self
        start: self
        get.period: self ." Period' = " . cr
        get.octave: self ." Octave = " . cr
        ?quit IF leave THEN
        finish: self
        3 2 */
    LOOP drop da.kill
;M

:M TEST.PART: ( start end -- , hear part of a waveform )
    da.stop
    swap data.addr: self over +  ( start byte )
    rot rot - da.sample!
    da.start
;M

:M PUT.#BLOCKS:  ( #blocks -- )
    iv=> iv-sm-#blocks
;M

:M GET.#BLOCKS:  ( -- #blocks )
    iv-sm-#blocks
;M

\ Draw data as blocks to show envelope.
\ This speeds up the drawing of long shapes by 7X.
: DRAW.DIM.FAST  ( start end count -- )
    0= NOT
    IF " DRAW.DIM.FAST" " Only dim=0 allowed!"
       er_return ob.report.error
    THEN
    many: self 1 >
    IF  over ( -- s e s )
        - dup iv-sm-#blocks /   1 max ( -- s diff per )
        tuck / 0  ( don't do more than start-end )
        DO  ( -- s per)
            0 0 3 pick i2addr: self 3 pick
            ( -- s per 0 0 addr per )
            min.max.bytes
            ( -- s per min max )
            >r >r 2dup over + r> swap r>
            scg.rect
            dup>r + r>
            service.tasks/16
        LOOP
    THEN 2drop
;

:M DRAW.DIM: ( start end dim -- , draw as blocks )
    >r 2dup - abs iv-sm-#blocks <
    IF r> draw.dim: super
    ELSE r> draw.dim.fast
    THEN
;M

:M REVERSE: ( start end dim -- , reverse bytes )
    0=
    IF i2addr: self >r i2addr: self r>
       reverse.bytes
    ELSE . . cr
         " REVERSE: OB.SAMPLE" " Only supports dim=0 !"
         er_return ob.report.error
    THEN
;M

:M DECIMATE: ( -- , remove every other sample )
    many: self 2/  ( -- m/2 )
    dup 0
    DO  i 2* at.self  ( -- m/2 sample v )
        i to.self
    LOOP
    set.many: self
    get.#oneshot: self 2/ put.#oneshot: self
    get.#repeat: self 2/ put.#repeat: self
;M

;CLASS

\ Create stock waveforms ------------------------------------
OB.WAVEFORM WAVE-SAWTOOTH
OB.WAVEFORM WAVE-1
OB.WAVEFORM WAVE-2

: WAVE.INIT
    8 new: wave-sawtooth
    8 0 DO
       -128 i 36 * + add: wave-sawtooth
    LOOP
\
    16 new: wave-1
    8 0 DO
       -128 i 32 * + add: wave-1
    LOOP
    8 0 DO
       127 i 32 * - add: wave-1
    LOOP
\
    32 new: wave-2
    32 0 DO
       256 choose add: wave-2
    LOOP
\
\ Allocate some zero CHIP RAM for silence.
    addr-of-zero @ 0=
    IF  MEMF_CHIP MEMF_CLEAR | 4 allocblock
        addr-of-zero !
    THEN
;

: WAVE.TERM
    addr-of-zero @ ?dup
    IF freeblock
       0 addr-of-zero !
    THEN
    free: wave-sawtooth
    free: wave-1
    free: wave-2
;

: SYS.INIT sys.init wave.init ;
: SYS.TERM wave.term sys.term ;


false .IF

OB.SAMPLE BIRD

: LB load: bird ;
: LOAD.BIRD
    " vd0:pc" lb
    clear: shape-holder
    bird add: shape-holder
;
: PB print: bird ;
: TB test: bird ;
: TPO PERIOD>OCTAVE: BIRD . . CR ;

.THEN
