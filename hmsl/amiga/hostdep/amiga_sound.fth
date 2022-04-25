\ Sound driver for Amiga
\
\ This version directly accesses the hardware registers.
\ This can interfere with other tasks which might try
\ to access the sound chips too.
\ The next version will allocate the channels.
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\ All Rights Reserved
\
\ MOD: PLB 7/25/86 Added DA.ENVELOPE! & DA.CATCH
\ MOD: PLB 1/13/87 Put CR in DA.TEST1, save values for readback.
\ MOD: PLB 2/28/87 Added DA.AMPMOD@., copy waves to CHIP ram.
\ MOD: PLB 3/6/87  Added DA.FREQ! and @ , and DA.PL->F
\ MOD: PLB 5/24/87 Add SYS.INIT
\ MOD: PLB 11/16/87 Add DA.LOUDNESS@, prettier DA.TEST.
\ MOD: PLB 3/28/89 Clear DA-WAVE-STORAGE in DA.TERM, fix
\ MOD: PLB 1/22/90 Add DA.FILTERS.OFF, Event Buffering Hooks
\ MOD: PLB 3/6/90 Added DA.READY? , DA.START.MANY , DA.STOP.MANY
\ MOD: PLB 3/26/90 Add DA.QUIET  - thanks Martin Kees
\ MOD: PLB 4/14/90 Disable AUD3 if used by timer.

include? c, ju:ajf_dict
include? msec ju:msec

ANEW TASK-AMIGA_SOUND

\ Define Register Locations
HEX 
DFF000 CONSTANT AMIGA_CHIP_BASE
10 CONSTANT ADKCONR_OFFSET
9E CONSTANT ADKCONW_OFFSET
A0 CONSTANT AUDXLCH_OFFSET
A4 CONSTANT AUDXLEN_OFFSET
A6 CONSTANT AUDXPER_OFFSET
A8 CONSTANT AUDXVOL_OFFSET
AA CONSTANT AUDXDAT_OFFSET
96 CONSTANT DMACONW_OFFSET
2  CONSTANT DMACONR_OFFSET

\ Flags for setting bits.
8000 CONSTANT SET/CLR
0200 CONSTANT DMA_DMAEN
0001 CONSTANT AUD0EN
0002 CONSTANT AUD1EN
0004 CONSTANT AUD2EN
0008 CONSTANT AUD3EN

DECIMAL
\ Stock Audio Waveforms, 8 samples long.
\ Templates for waves to be copied to chip memory.
Create DA-WAVE-TEMPLATE HERE
( Sine)     0 c, 90 c, 127 c, 90 c, 0 c, -90 c, -128 c, -90 c,
( Sawtooth) -128 dup c, 36 + dup c, 36 + dup c, 36 + dup c,
                   36 + dup c, 36 + dup c, 36 + dup c, 36 + c,
( Triangle) -128 c, -64 c, 0 c, 63 c, 127 c, 63 c, 0 c, -64 c,
( Pulse)    -128 c, -128 c, 127 c, 127 c, 127 c, 127 c, 127 c, 127 c,
( Complex)  -128 c, 92 c, 0 c, -81 c, 32 c, 12 c, 55 c, 100 c,
HERE swap - constant DA_WAVE_SPACE ( memory required )
VARIABLE DA-WAVE-STORAGE   ( Pointer to waves in chip memory )

0 CONSTANT DA_SINE
1 CONSTANT DA_SAWTOOTH
2 CONSTANT DA_TRIANGLE
3 CONSTANT DA_PULSE
4 CONSTANT DA_COMPLEX

4 Constant DA_NUM_CHANNELS
\ Store data in arrays for readback.
\ The AMIGA registers are write only.
da_num_channels array DA-ADDRESSES
da_num_channels array DA-LENGTHS
da_num_channels array DA-VOLUMES
da_num_channels array DA-PERIODS
da_num_channels array DA-AMPMODS
da_num_channels array DA-FREQMODS

variable DA-CHANNEL  ( Channel number 0-3 )
variable DA-MAX-CHANNEL
3 da-max-channel !
variable DA-OFFSET   ( Offset to channel registers )

\ Chip Register Access Words
\ These are used by the Event Buffering System
\ The parameters need to be packed into a 32 bit cell.
defer DA.CHIPW!  ( value16 offset16 -- , store into chip )
defer DA.CHIP!   ( value24 offset8 -- , store at 8 bit offset )

: (DA.CHIPW!)  ( value16 offset16 -- , store into chip )
    amiga_chip_base + absw!
;
'c (da.chipw!) is da.chipw!

: (DA.CHIP!)   ( value24 offset8 -- , store at 8 bit offset )
    amiga_chip_base + abs!
;

'c (da.chip!) is da.chip!

: DA.CHANNEL!  ( channel[0-3] -- , set channel to control )
    dup da-max-channel @ >
    IF  ." Error - Highest DA channel is "
        da-max-channel @ dup . cr
        2 = 
        IF ." Channel 3 being used by timer!" cr
        THEN
        drop 2
    ELSE 0 max
    THEN
    dup da-channel !
    4 ashift da-offset !
;

: DA.OFF+ ( addr -- addr' , offset to proper channel )
    da-offset @ +
;

: DA.#WORDS!   ( #words -- , set word length of sample )
    dup AUDXLEN_OFFSET da.off+ da.chipw!
    da-channel @ da-lengths !
;

: DA.#WORDS@   ( -- #words , length of sample )
    da-channel @ da-lengths @
;

: DA.ADDRESS!  ( addr -- , address of first byte )
    dup >abs AUDXLCH_OFFSET da.off+ da.chip!
    da-channel @ da-addresses !    
;

: DA.ADDRESS@  ( -- addr , address of first byte )
    da-channel @ da-addresses @
;

: DA.ENVELOPE! ( addr #words -- , set envelope registers )
    da.#words!  da.address!    
;

: DA.SAMPLE! ( addr #bytes -- , Set Sample to Use )
    2/ da.envelope!
;

: DA.SAMPLE@ ( -- addr #bytes , Fetch Sample in Use )
    da.address@ da.#words@ 2*
;

: DA.WAVE!   ( choice -- , select preset waveform )
    3 ashift ( 8* )
    da-wave-storage @ +  8  da.sample!
;

: DA.VOLUME! ( volume -- , Set volume for channel, 0 to 64 )
     dup AUDXVOL_OFFSET da.off+ da.chipw!
     da-channel @ da-volumes !
;

: DA.VOLUME@ ( -- volume , get volume for channel)
     da-channel @ da-volumes @
;

: DA.LOUDNESS! ( loudness -- , Set loudness , volume to laymen. )
     da.volume!
;

: DA.LOUDNESS@ ( -- loudness , Fetch loudness. )
     da.volume@
;

: DA.PERIOD! ( period -- , Set period between samples, 1/frequency )
     dup AUDXPER_OFFSET da.off+ da.chipw!
     da-channel @ da-periods !
;

: DA.PERIOD@ ( -- period , get period  )
     da-channel @ da-periods @
;

\ Conversion between period and frequency.
\ This one word converts both ways.
\ From hertz to period or vice versa.
: DA.FL->P  ( frequency[hz] length_in_bytes -- period )
    *   3,579,547 swap /
;

\ This works for repetitive waveforms after setting length.
\ WARNING! This is much slower than specifying period directly.
: DA.FREQ! ( freq -- , set frequency for channel )
    da.#words@ 2* da.fl->p da.period!
;

: DA.FREQ@ ( -- freq , fetch frequency of channel )
    da.period@ da.#words@ 2* da.fl->p
;

variable DA-CATCH-MSEC    0 da-catch-msec !
: DA.CATCH ( -- , Wait for values to get latched )
    da.period@ 1 da.period!
    da-catch-msec @ msec
    da.period!
;

: DA.FREQMOD! ( flag -- , control frequency modulation mode )
    dup da-channel @ da-freqmods !
    IF SET/CLR ELSE 0 THEN
    16 da-channel @ ashift OR ADKCONW_OFFSET da.chipw!
;

: DA.AMPMOD! ( flag -- , control amplitude modulation mode )
    dup da-channel @ da-ampmods !
    IF SET/CLR ELSE 0 THEN
    1  da-channel @ ashift OR ADKCONW_OFFSET da.chipw!
;

: DA.FREQMOD@ ( -- flag , is frequency modulation mode on?)
    da-channel @ da-freqmods @
;

: DA.AMPMOD@ ( -- flag , is amplitude modulation mode on?)
    da-channel @ da-ampmods @
;

: DA.START.MANY ( mask -- , bit for each channel, F=all )
    SET/CLR OR DMA_DMAEN OR DMACONW_OFFSET da.chipw!
;

: DA.START ( -- , start audio for current channel )
    1 da-channel @ ashift
    da.start.many
;

: DA.STOP.MANY ( mask -- , bit for each channel, F=all )
    DMACONW_OFFSET da.chipw!
;
: DA.STOP ( -- , stop audio for current channel )
    1 da-channel @ ashift
    da.stop.many
;

: DA.KILL  ( -- , stop all Amiga Audio )
    DA_NUM_CHANNELS 0 DO 
        i da.channel! da.stop
    LOOP
;

: DA.QUIET  ( -- , silence all Amiga Audio )
    DA_NUM_CHANNELS 0 DO 
        i da.channel!
        0 da.loudness!
    LOOP
;

$ DFF01E constant INTREQR
$ DFF09C constant INTREQ

: DA.READY?  ( -- channelbit , !=0 if ready )
    $ 80 da-channel @ +shift  \ make mask
    intreqr absw@ and dup     \ check bit
    IF dup intreq absw!       \ clear if on
    THEN
;

: DA.INITCH ( channel -- , setup a channel )
    dup da.channel! da.wave!
    428 da.period!
    64 da.volume!
    0 da.freqmod!
    0 da.ampmod!
    da.stop
;

.NEED Disable()
: Disable()  ( -- , disable interrupts )
    callvoid exec_lib disable
;
: Enable()  ( -- , enable interrupts )
    callvoid exec_lib enable
;
.THEN

\ These next 2 words work by setting a bit which controls
\ the cutoff filters. You can get a brighter sound by
\ turning them off. The bit is shared with the Power LED!
: DA.FILTERS.OFF ( -- turn off filters )
    disable() $ BFE001 absc@ 2 OR $ BFE001 absc! enable()
;
: DA.FILTERS.ON ( -- turn off filters )
    disable() $ BFE001 absc@ $ FD and $ BFE001 absc! enable()
;

: DA.INIT  ( -- , Initialize Digital Audio System )
\ Allocate chip RAM for waveforms.
    da-wave-storage @ 0=
    IF MEMF_CHIP da_wave_space allocblock ?dup
       IF da-wave-storage !
          da-wave-template da-wave-storage @ da_wave_space cmove
       ELSE true warning" DA.INIT - No space for waveforms!"
       THEN
    THEN
    DA_NUM_CHANNELS 0 DO
        i da.initch
    LOOP
    1 da.channel!
;

: DA.TERM   ( -- , Terminate Digital Audio )
    da.kill
    da-wave-storage @ ?dup  ( free storage if allocated )
    IF  freeblock
        da-wave-storage off
    THEN
;

if.forgotten da.term

: DA.TESTCH  ( period channel -- , test )
    da.channel!  da.period!
    da.start 
    ." key for next note" CR
    key drop
;

: DA.TEST  ( -- , test sound output )
    da.init cr
    600 0 da.testch
    450 1 da.testch
    400 2 da.testch
    300 3 da.testch
    da.kill
;

: SYS.INIT sys.init da.init ;
: SYS.RESET da.kill sys.reset ;
: SYS.TERM da.term sys.term ;
