\ Simple notation system for entering song data.
\
\ Author: Phil Burk
\ Copyright 1988 Phil Burk
\
\ MOD: PLB 8/31/89 Add H. etc. from Larry
\ MOD: PLB 11/16/89 Added MM! and set TPW to DEFAULT_TPW
\ MOD: PLB 3/13/90 Removed use of VOCABULARIES
\ MOD: JHC 9/11/90 1numeric codes, flats added
\ MOD: PLB 4/21/91 Merged J.Chalmers mods with mine
\           Changed NTET to NS-NOTES/OCT
\           Added <<< for more controllable CRESCENDI
\ MOD: PLB 5/?/91 Added SYNC.TO and other synchronization tools.
\ MOD: PLB 7/21/91 Fixed long last note in SHAPEI{
\ 00001 PLB 9/11/91 Fixed roundoff error accumulator, use ratios.
\ 00002 PLB 9/13/91 Add floating point acceleration.
\ 00003 PLB 9/25/91 Check for acceleration too close to 1.0, ln=0
\           Moved RATIO+ and REDUCE.FRACTION to H:MISC_TOOLS

exists? play{
[IF] only forth definitions
[THEN]

decimal

ANEW TASK-SCORE_ENTRY

false [IF]
This system can be used to build shapes for playback.
Assumptions:
    Dimension 0 of a shape is duration, time till next note.
    Dimension 1 of a shape is pitch.
Optional Dimensions:
    Dimension 2 of a shape is velocity/loudness if used.
    Dimension 3 of a shape is ON time.
    Dimension 4 of a shape is CFA of a unique interpreter.

Pitches are notated by note, eg.
The closest note will be used unless an OCTAVE command is used
which will force the octave.
    C#
    E
    or
    REST

Durations are notated by an irreducible fraction:
Valid fractions are:
    1/32 1/16 1/8 1/4 1/2 1/1 3/16 3/8 3/4
    1/3 1/6 1/12 1/5 1/7 1/10 1/14

Dynamics are specified by:
    _fff
    _ff
    _f
    _mf
    _mp
    _p
    _pp
    _ppp

Parallel sections are noted with:
    }play{

For example:

    play{
        1/4 c c g g
        par{ b f b f
        }par{ 1/8 c g a d e b
        }par
        1/4 b b b b
        chord{ c e g }chord
        1/32 c e c f c g c a c b c a c g c e c f c d
    }play

[THEN]

variable NS-CUR-SHAPE    \ shape currently being built
variable NS-CUR-INST     \ instrument currently being used

variable NS-CUR-VELOCITY \ velocity or loudness

variable NS-CRESC-T0     \ time at start of crescendo
variable NS-CRESC-DT     \ total time of crescendo
variable NS-CRESC-V0     \ velocity at start of crescendo
variable NS-CRESC-DV     \ velocity change of crescendo
variable NS-CRESC-BREAK? \ if true, turn off cresc above T1
variable NS-CRESCENDO?   \ if true, apply crescendo

exists? f**
[IF]
fvariable NS-FACCEL-SCALE
fvariable NS-FACCEL-BIGT
fvariable NS-FACCEL-T/lnA
[THEN]
variable NS-ACCEL-TIME   \ cumulative ticks in score time frame
variable NS-ACCELERATE   \ ticks per whole note to accel
variable NS-IF-ACCEL
variable NS-IF-FACCEL

variable NS-HUMANIZE     \ N/128 ths to vary time and velocity
variable NS-ACCENT       \ temporary loudness increase

\ These two variables + vtime
\ determine the current time and tempo
variable NS-WHOLE-NOTE   \ number of ticks per whole note
variable NS-ERR-NUMER    \ accumulated roundoff error numerator in ticks
variable NS-ERR-DENOM    \ accumulated roundoff error denominator in ticks

variable NS-DURATION     \ current duration in ticks
variable NS-DUR-NUMER    \ Numerator for recalculating dur
variable NS-DUR-DENOM    \ Denominator for recalculating dur
variable NS-DUR-REMAINS  \ remainder from duration calc
variable NS-ON-FACTOR    \ on time scaled by 128

variable NS-MODE         \ add to shape or play or ?
variable NS-NEST         \ depth of nested play{ }play
variable NS-IF-CHORD     \ true if accumulating chord
variable NS-CHORD-START  \ time of start of chord
variable NS-ARPEGGIATE   \ ticks between each note of arpeggiation
variable NS-CHORD-TIME   \ time for next note of chord
variable NS-LEAVE-VALUE  \ notes just leave value on stack if true
variable NS-OFFSET       \ offset to MIDI range if applicable
variable NS-NOTES/OCT    \ notes per octave for other tunings

12 NS-NOTES/OCT !
NS-NOTES/OCT @ NS-OFFSET !

\ Synchronization tools for synchronizing several parts
variable NS-START-TIME   \ vtime at beginning
variable NS-SYNC-REF

8 array NS-sync-ETIME
8 array NS-SYNC-WHOLE
8 array NS-SYNC-ERR-NUM
8 array NS-SYNC-ERR-DEN

\ Score variables
variable OCTAVE
variable TRANSPOSITION

0 constant ns_play_mode
1 constant ns_shape_mode
2 constant ns_inst_mode
3 constant ns_custom_mode
defer NS.ADD.CUSTOM

: NS.DETRANS  ( note -- note_index )
    ns-cur-inst @ detranslate: [] 0=
    IF ." Note not translatable to instrument!" cr 1
    THEN
;

: NS.ELAPSED ( -- elapsed time for play )
    vtime@ ns-start-time @ -
;

: NS.CALC.ONTIME ( dur -- ontime )
    ns-on-factor @ *
    -7 ashift  ( cheap 128 / )
;

: NS.ADD.SHAPE { dur notev vel | index -- }
    ns-cur-shape @ ?dup
    IF  dup>r
        many: [] 2+ r@ max.elements: [] >
        IF 8 r@ extend: []  ( -- make more room )
        THEN
        vtime@ 0 r@ search.back: [] -> index
        r@ dimension: []
        CASE
           2 OF vtime@ notev index r@ insert: [] ENDOF
           3 OF vtime@ notev vel index r@ insert: [] ENDOF
           4 OF vtime@ notev vel
                dur ns.calc.ontime index r@ insert: [] ENDOF
           " ADD.NOTE" " Illegal width for notated shape!"
           er_fatal er.report
        ENDCASE
        rdrop
        dur vtime+!
    ELSE " ADD.NOTE"
         " Shape must be specified first by calling SHAPEI{"
         er_fatal er.report
    THEN
;

: NS.HUMANIZE  ( value -- value' , tweak, you must clip )
    ns-humanize @ ?dup
    IF choose+/- over * -7 ashift +
    THEN
;

: NS.SET.LENGTH  ( numer denominator -- , eg. 1 4 for quarter notes )
    dup ns-dur-denom !
    over ns-dur-numer !
    ns-whole-note @ -rot
    */mod ns-duration ! ns-dur-remains !
;

: NS.RECALC.TPW ( tpw -- , recalculate error, etc )
\ rescale error by current whole note
    dup ns-err-numer @ ns-whole-note @ */ ns-err-numer !
    ns-whole-note !
    ns-dur-numer @ ns-dur-denom @ ns.set.length
;

\ Synchronization
: ZERO.SYNC  ( -- , zero reference for sync )
    vtime@ ns-sync-ref !
;

: SET.SYNC  ( n -- , record a sync point )
    vtime@ ns-sync-ref @ - over ns-sync-etime !
    ns-whole-note @ over ns-sync-whole !
    ns-err-numer @ over ns-sync-err-num !
    ns-err-denom @ swap ns-sync-err-den !
;

: SYNC.TO  ( n -- , synchronize to point N )
    dup ns-sync-etime @ ns-sync-ref @ + vtime!
    dup ns-sync-whole @ ns-whole-note !
    dup ns-sync-err-num @ ns-err-numer !
        ns-sync-err-den @ ns-err-denom !
;

exists? S>F
[IF]
defer STIME>ATIME ( score_time -- accelerated_time )

: NS.ST>AT ( score_time -- accelerated_time )
\ dup .
    s>f
\ fdup f.
    ns-faccel-bigt f@ f/
    ns-faccel-scale f@
    fswap f**
\ fdup f.
    1.0 f-
    ns-faccel-t/lna f@ f*
\ fdup f. cr
    f>s
;

' ns.st>at is stime>atime

: NS.ACCELERATE.FP { dur | dur' -- dur' }
    ns-accel-time @ dur + stime>atime
    ns-accel-time @ stime>atime
    - -> dur'
    dur ns-accel-time +!
    dur'
;
[ELSE]
: NS.ACCELERATE.FP ( dur -- dur' , stub! )
;
[THEN]

: NS.ACCELERATE.INT  ( dur -- dur' , process any acceleration )
    ns-accelerate @ ?dup
    IF over * -7 ashift
       ns-whole-note @ + 4 max ns.recalc.tpw
    THEN
;

: NS.ACCELERATE ( dur -- dur' )
    ns-if-faccel @
    IF
        ns.accelerate.fp
    ELSE
        ns-if-accel @
        IF
            ns.accelerate.int
        THEN
    THEN
;

: (NS.FIX.DUR)  ( dur -- dur' , account for roundoff error )
\ Add a little bit to error accumulator if current note
\ length is not exact.
    ns-dur-remains @
    IF
        ns-dur-remains @ ns-dur-denom @
        ns-err-numer @ ns-err-denom @
        ratio+
        reduce.fraction
        30000 clip.fraction
        ns-err-denom ! ns-err-numer !
    THEN
\
\ Check to see if we have accumulated enough to add one tick
\ to the current duration and work off some error.
    ns-err-numer @ ?dup
    IF ns-err-denom @ >=
       IF 1+  ( add a tick to dur )
          ns-err-denom @ negate ns-err-numer +! ( work off error )
       THEN
    THEN
\
\ perform other post processing
    ns.accelerate
;

: NS.FIX.DUR ( dur -- dur' , account for roundoff error )
    ns-if-chord @ not
    IF (ns.fix.dur)
    THEN
;

defer PLAY.NOTE.FOR ( note velocity ontime -- )

exists? midi.noteon.for [IF]
' midi.noteon.for is play.note.for
[THEN]

: NS.PLAY.NOTE ( dur note velocity -- , add to event buffer )
    2 pick ns.calc.ontime play.note.for
    vtime+!
;

: NS.PLAY.INST ( dur note_index velocity -- , add to event buffer )
    2 pick ns.calc.ontime
    ns-cur-inst @ note.on.for: []
    vtime+!
;

: NS.CHORD.TIME ( -- , set vtime if in chord )
    ns-if-chord @
    IF ns-chord-time @ dup vtime!
       ns-arpeggiate @ + ns-chord-time !
    THEN
;

variable HUMANIZE-OFFSET
: HUMANIZE ( maxticks -- , offset vtime )
    choose+/- dup humanize-offset +!
    vtime+!
;

: DEHUMANIZE ( -- , remove effect of humanization )
    humanize-offset @ negate vtime+!
    humanize-offset off
;

: NS.NEXT.NOTE ( dur note velocity -- )
    ns-humanize @ ?dup
    IF 3 pick * -7 ashift humanize
    THEN
    ns.chord.time
    ns-mode @
    CASE
        ns_shape_mode OF ns.add.shape ENDOF
        ns_play_mode OF ns.play.note ENDOF
        ns_inst_mode OF ns.play.inst ENDOF
        ns_custom_mode OF ns.add.custom ENDOF
        ." Illegal notation mode!" abort
    ENDCASE
    dehumanize
;

: NS.ACCENT  ( velocity -- velocity' , add accent )
    ns-accent @ +
\ accent whole chord
    ns-if-chord @ not
    IF ns-accent off
    THEN
;


: NS.CRESC.OFF  ( -- )
    ns-crescendo? off
    ns-cresc-break? off
;


: (NS.CALC.CRESC) ( -- , apply crescendo )
    ( linear interpolate )
    vtime@ ns-cresc-t0 @ -  ( dt )
    ns-cresc-dv @ * ( dv*dt )
    ns-cresc-dt @ / ( dv*dt/tt )
    ns-cresc-v0 @ +
    1 127 clipto ns-cur-velocity !
;

: NS.CALC.CRESC ( -- , apply crescendo if active)
    ns-crescendo? @
    IF
        ns-cresc-break? @
        IF
            vtime@
            ns-cresc-t0 @ ns-cresc-dt @ + >
            IF
                ns.cresc.off
                ns-cresc-v0 @ ns-cresc-dv @ +
                1 127 clipto
                ns-cur-velocity !
            ELSE
                (ns.calc.cresc)  ( still in it )
            THEN
        ELSE
            (ns.calc.cresc)  ( just keep going )
        THEN
    THEN
;


: NS.GET.VELOCITY ( -- velocity , +/- crescendo, humanize, accent )
    ns.calc.cresc
    ns-cur-velocity @
\
    ns.humanize
    ns.accent
    1 127 clipto
;

: NOTE ( note -- )
    ns-duration @ ns.fix.dur
    swap transposition @ +
    ns.get.velocity ns.next.note
;

: REST  ( -- , rest for current duration )
    ns-duration @ ns.fix.dur vtime+!
;

: NS.CALC.NOTE  ( note-midi -- note-index , add octave, => index )
    octave @ ns-notes/oct @ * + ns-offset @ +  ( start at second octave )
    ns-cur-inst @
    IF ns.detrans
    THEN
;

: (NS.NOTE) ( note -- )
    ns.calc.note
    ns-leave-value @ 0=
    IF  note  ( play if not value mode )
    THEN
;

: NS.NOTE: \ define a note generator
    CREATE ( value -- )
        w,
    DOES> ( addr -- )
        w@ (ns.note)
;

: NS.NOCT: \ define a note and octave generator
    CREATE ( value -- )
        octave @ c, c, ( octave then note )
    DOES> dup c@ octave ! 1+ c@ (ns.note)
;

: NS.DURATION@ ( duration_pfa -- numer denom )
    dup w@ swap 2+ w@  ( numer denom )
;

: NS.DURATION: \ add note of given time to shape
    CREATE ( numerator denominator -- )
        swap w, w,
    DOES> ( addr -- )
        ns.duration@
        ns.set.length
;

: NS.VELOCITY!  ( velocity -- )
    ns-cur-velocity !
    ns.cresc.off
;

: NS.DYNAMIC:  \ define a dynamic indicator
    CREATE  ( velocity -- )
        w,
    DOES> w@ ns.velocity!
;

\ Base default ticks per whole note on clock rate when compiled.
: BPM>TPW  { bpm -- tpw , convert beats per minute to ticks per whole note }
    rtc.rate@ \ ticks per second
    60        \ seconds per minute
    *         \ ticks per minute
    bpm       \ beats per minute, default tempo
    /         \ ticks per beat
    4         \ beats per whole note
    *         \ ticks per whole note
;

120 bpm>tpw value DEFAULT_TPW

: NS.RESET  ( -- )
    80 ns-cur-velocity !  ( forte )
    ns.cresc.off
    default_tpw ns-whole-note !
    80 ns-on-factor !
    4 octave !
    transposition off
    0 ns-err-numer !
    1 ns-err-denom !
    0 ns-dur-remains !
    0 ns-cur-inst !
    0 ns-cur-shape !
    0 transposition !
    1 4 ns.set.length
    ns-if-chord off
;

: NS.SETUP ( -- )
    ns.reset
    0 ns-nest !
;

\ Don't use Vocabularies because they are a pain.
FALSE constant SES_USE_VOCAB
SES_USE_VOCAB [IF]

vocabulary notation

: SCORE{  ( -- , initialize score system and set vocab )
    ns.setup
    also notation
;
: }SCORE  ( -- , stop scoring )
    only forth definitions
;
also notation definitions

[ELSE]

: HEX  ( -- , change base )
    >newline
    ." Warning - Potential conflict between note names and" cr
    ." hexadecimal numbers. Use $ for hex numbers: $ C3" cr
    HEX
;
: SCORE{  ( -- , initialize score system )
    ns.setup
    hex decimal
;
: }SCORE  ( -- , nada )
;

score{

[THEN]


\ Play using an HMSL instrument.
: INSTR{  ( inst -- )
    ns-cur-inst !
    ns_inst_mode ns-mode !
    1 ns-nest !
;

: }INSTR ( -- )
    0 ns-cur-shape !
    0 ns-cur-inst !
    ns_play_mode ns-mode !
    -1 ns-nest +!
    ns-nest @
    IF  ." Unbalanced INSTR{ or SHAPEI{" cr
        0 ns-nest !
    THEN
;

: SHAPEI{ ( shape inst -- )
    ns-cur-inst !
    dup clear: []  ns-cur-shape !
    ns_shape_mode ns-mode !
    1 ns-nest !
    0 dup vtime! ns-start-time !
;

: }SHAPEI ( -- )
\   ns-cur-shape @ print: []
    ns.elapsed
\ This next line is to correct problems with long last notes
\ caused by VTIME getting advanced after SHAPEI{
\ Subtract the start time for the first note.
    0 0 ns-cur-shape @ ed.at: [] -  ( account for delayed starts )
\
    0 ns-cur-shape @ differentiate: []
    }instr
;

\ Play using direct MIDI
: PLAYAT ( vtime -- )
    ns_play_mode ns-mode !
    ns.reset
    dup vtime! ns-start-time !
;

: PLAYNOW ( -- , use current time )
    time@ playat
;

\ Change Tempo by changing ticks per whole note
: TPW!  ( ticks -- , set ticks per whole note )
    ns.recalc.tpw
;

: TPW@  ( -- ticks )
    ns-whole-note @
;

: TPW+! ( ticks -- , change ticks per whole note )
    tpw@ + tpw!
;

: PAR.PUSH ( vtime-start vtime-end accel-time tpw -- )
    vtime.push vtime.push vtime.push vtime.push
;

: PAR.POP ( -- vtime-start vtime-end accel-time tpw )
    vtime.pop vtime.pop vtime.pop vtime.pop
;

: PAR{  ( -- )
    vtime@
    dup
    ns-accel-time @
    tpw@
    par.push
;

: }PAR{ ( -- )
    par.pop  ( -- vtime-start vtime-end accel-time tpw )
    dup tpw@ -  ( reset tpw if changed )
    IF dup tpw!
    THEN
    >r dup ns-accel-time !
    >r vtime@ max
    >r dup vtime!
    r> r> r>
    par.push
;

: }PAR ( -- )
    par.pop
    drop drop
    vtime@ max vtime!
    drop
;

\ define NS-NOTES/OCT - 1 notes
0 ns.note: C
1 ns.note: C#
1 ns.note: Db
2 ns.note: D
3 ns.note: D#
3 ns.note: Eb
4 ns.note: E
5 ns.note: F
6 ns.note: F#
6 ns.note: Gb
7 ns.note: G
8 ns.note: G#
8 ns.note: Ab
9 ns.note: A
10 ns.note: A#
10 ns.note: Bb
11 ns.note: B

0 octave !
0 ns.noct: C0  1 ns.noct: C#0 2 ns.noct: D0   3 ns.noct: D#0
4 ns.noct: E0  5 ns.noct: F0  6 ns.noct: F#0  7 ns.noct: G0
8 ns.noct: G#0 9 ns.noct: A0  10 ns.noct: A#0 11 ns.noct: B0
1 ns.noct: Db0 3 ns.noct: Eb0  6 ns.noct: Gb0  8 ns.noct: Ab0
10 ns.noct: Bb0


1 octave !
0 ns.noct: C1  1 ns.noct: C#1 2 ns.noct: D1   3 ns.noct: D#1
4 ns.noct: E1  5 ns.noct: F1  6 ns.noct: F#1  7 ns.noct: G1
8 ns.noct: G#1 9 ns.noct: A1  10 ns.noct: A#1 11 ns.noct: B1
1 ns.noct: Db1 3 ns.noct: Eb1  6 ns.noct: Gb1  8 ns.noct: Ab1
10 ns.noct: Bb1

2 octave !
0 ns.noct: C2  1 ns.noct: C#2 2 ns.noct: D2   3 ns.noct: D#2
4 ns.noct: E2  5 ns.noct: F2  6 ns.noct: F#2  7 ns.noct: G2
8 ns.noct: G#2 9 ns.noct: A2  10 ns.noct: A#2 11 ns.noct: B2
1 ns.noct: Db2 3 ns.noct: Eb2  6 ns.noct: Gb2  8 ns.noct: Ab2
10 ns.noct: Bb2

3 octave !
0 ns.noct: C3  1 ns.noct: C#3 2 ns.noct: D3   3 ns.noct: D#3
4 ns.noct: E3  5 ns.noct: F3  6 ns.noct: F#3  7 ns.noct: G3
8 ns.noct: G#3 9 ns.noct: A3  10 ns.noct: A#3 11 ns.noct: B3
1 ns.noct: Db3 3 ns.noct: Eb3  6 ns.noct: Gb3  8 ns.noct: Ab3
10 ns.noct: Bb3


4 octave !
0 ns.noct: C4  1 ns.noct: C#4 2 ns.noct: D4   3 ns.noct: D#4
4 ns.noct: E4  5 ns.noct: F4  6 ns.noct: F#4  7 ns.noct: G4
8 ns.noct: G#4 9 ns.noct: A4  10 ns.noct: A#4 11 ns.noct: B4
1 ns.noct: Db4 3 ns.noct: Eb4  6 ns.noct: Gb4  8 ns.noct: Ab4
10 ns.noct: Bb4

5 octave !
0 ns.noct: C5  1 ns.noct: C#5 2 ns.noct: D5   3 ns.noct: D#5
4 ns.noct: E5  5 ns.noct: F5  6 ns.noct: F#5  7 ns.noct: G5
8 ns.noct: G#5 9 ns.noct: A5  10 ns.noct: A#5 11 ns.noct: B5
1 ns.noct: Db5 3 ns.noct: Eb5  6 ns.noct: Gb5  8 ns.noct: Ab5
10 ns.noct: Bb5

6 octave !
0 ns.noct: C6  1 ns.noct: C#6 2 ns.noct: D6   3 ns.noct: D#6
4 ns.noct: E6  5 ns.noct: F6  6 ns.noct: F#6  7 ns.noct: G6
8 ns.noct: G#6 9 ns.noct: A6  10 ns.noct: A#6 11 ns.noct: B6
1 ns.noct: Db6 3 ns.noct: Eb6  6 ns.noct: Gb6  8 ns.noct: Ab6 10 ns.noct: Bb6

7 octave !
0 ns.noct: C7  1 ns.noct: C#7 2 ns.noct: D7   3 ns.noct: D#7
4 ns.noct: E7  5 ns.noct: F7  6 ns.noct: F#7  7 ns.noct: G7
8 ns.noct: G#7 9 ns.noct: A7  10 ns.noct: A#7 11 ns.noct: B7
1 ns.noct: Db7 3 ns.noct: Eb7  6 ns.noct: Gb7  8 ns.noct: Ab7
10 ns.noct: Bb7


2 1  ns.duration: 2/1
1 1  ns.duration: 1/1
1 2  ns.duration: 1/2
1 4  ns.duration: 1/4
1 8  ns.duration: 1/8
1 16 ns.duration: 1/16
1 32 ns.duration: 1/32
3 2  ns.duration: 3/2
3 4  ns.duration: 3/4
3 8  ns.duration: 3/8
3 16 ns.duration: 3/16
1 3  ns.duration: 1/3
1 6  ns.duration: 1/6
1 12 ns.duration: 1/12
1 5  ns.duration: 1/5
1 10 ns.duration: 1/10
1 7  ns.duration: 1/7
1 14 ns.duration: 1/14

\ Alternative Time specifications
1 1  ns.duration: W1
1 2  ns.duration: H1
1 4  ns.duration: Q1
1 8  ns.duration: EH1
1 16 ns.duration: S1

3 2  ns.duration: W1.
3 4  ns.duration: H1.
3 8  ns.duration: Q1.
3 16 ns.duration: EH1.
3 32 ns.duration: S1.

1 3  ns.duration: H3
1 6  ns.duration: Q3
1 12 ns.duration: EH3
1 24 ns.duration: S3

\ Dotted triplets are the same as the normal length.
1 2  ns.duration: H3.
1 4  ns.duration: Q3.
1 8  ns.duration: EH3.
1 16 ns.duration: S3.

1 5  ns.duration: H5
1 10 ns.duration: Q5
1 20 ns.duration: EH5
1 40 ns.duration: S5

3 10 ns.duration: H5.
3 20 ns.duration: Q5.
3 40 ns.duration: EH5.
3 80 ns.duration: S5.

: DURATION!!  ( numer denom -- , set note length )
    ns.set.length
;
: (TIE)  ( duration_pfa -- , execution time word for tie )
    ns.duration@  ( -- numer denom )
    ns-dur-numer @ ns-dur-denom @
    ratio+  reduce.fraction
    30000 clip.fraction
    duration!!
;

: TIE  ( <length> -- )
    ho.find.pfa
    IF  state @
        IF [compile] aliteral compile (tie)
        ELSE (tie)
        THEN
    ELSE ." TIE duration not found!" abort
    THEN
; immediate

100 7 /  ( calculate difference between dynamic levels )
126    dup ns.dynamic: _fff
over - dup ns.dynamic: _ff
over - dup ns.dynamic: _f
over - dup ns.dynamic: _mf
over - dup ns.dynamic: _mp
over - dup ns.dynamic: _p
over - dup ns.dynamic: _pp
over - dup ns.dynamic: _ppp
2drop

: LOUDNESS!  ( 0-127 -- , set loudness )
    0 127 clipto ns.velocity!
;

: LOUDNESS@  ( 0-127 -- , set loudness )
    ns-cur-velocity @
;

: /\  ( accent -- , temporary increase in volume )
    ns-accent !
;

: MM->TPW  ( mm -- tpw , convert metronome to ticks/whole )
 \ t/w = (60 t/sec)*(60 secs/min)*(4 qn/w) / ( mm qn/min )
    [ 60 4 * ] literal rtc.rate@ * swap /
;

: MM!  ( mm - , set metronome tempo )
    mm->tpw tpw!
;

: MM@  ( -- mm )
    tpw@ mm->tpw ( yes!)
;

: HUMANIZE! ( n/128 -- )
    0 128 clipto ns-humanize !
;

: STACCATO!  ( n/128 -- )
    ns-on-factor !
;

: STACCATO  ( -- , set on-factor to short value )
    32 staccato!
;

: END.STACCATO ( -- )
    80 staccato!
;

: LEGATO  ( -- )
    129 staccato!
;

: END.LEGATO  ( -- )
    end.staccato
;

exists? s>f
[IF]
: FACCEL{  ( factor  numer denom -- )
\
\ calculate ticks to accelerate by factor
    >r tpw@ * s>f  \ numer
    r> s>f \ denom
    f/ ns-faccel-bigT f!
\
    1.0 fswap f/  ( invert for more intuitive interface )
    fdup ns-faccel-scale f!
\
\ calculate constant for accelaration
    fln \ check to see if LOG is too close to zero 00003
    fdup fabs 0.00000001 f<
    IF
        >newline
        f. ." = fln(acceleration_factor) , factor too close to 1.0" cr
        false ns-if-faccel !
    ELSE
        ns-faccel-bigT f@
        fswap f/ ns-faccel-T/lnA f!
\
        0 ns-accel-time !
        true ns-if-faccel !
    THEN
;

: }FACCEL ( -- , stop acceleration, calc new TPW )
    ns-faccel-scale f@
    ns-accel-time @ s>f
    ns-faccel-bigt f@ f/
    f**
    tpw@ s>f f*
    f>s tpw!
    false ns-if-faccel !
;
[THEN]

: ACCEL{ ( N/128 -- , set acceleration in n/128 per note )
    ns-whole-note @ ns-duration @ */
    negate ns-accelerate !
    0 ns-accel-time !
    true ns-if-accel !
;
: }ACCEL ( -- )
    0 ns-accelerate !
    false ns-if-accel !

;

: SET.CRESCENDO  ( dvel dticks break? -- )
    ns-cresc-break? !
    ns-cresc-dt !
    ns-cresc-dv !
    vtime@ ns-cresc-t0 !
    ns-cur-velocity @ ns-cresc-v0 !
    ns-crescendo? on
;

: <<< ( dvel  durnumer durdenom -- , set crescendo )
    >r tpw@ * r> /
    true
    set.crescendo
;

: >>> ( dvel durnumer durdenom -- , set DEcrescendo )
    >r >r negate r> r>
    <<<
;

: // ( dvel -- , start crescendo )
    ?dup
    IF
        ns-duration @ false set.crescendo
    ELSE
        ns.cresc.off
    THEN
;
: \\ ( value -- , start decrescendo )
    negate //
;

\ Aliases for // and \\
: <<<{ // ;
: >>>{ \\ ;
: }>>> 0 // ;
: }<<< 0 // ;

: ARPEG{ ( ticks -- , arpeggiated chord )
    ns-arpeggiate !
    ns-if-chord on
    vtime@ dup ns-chord-time ! ns-chord-start !
;

: CHORD{ ( -- , start accumulating chord )
    0 arpeg{
;

: }ARPEG ( -- )
    ns-if-chord off
    ns-accent off
    ns-chord-start @
    ns-duration @ ns.fix.dur + vtime!
;

: }CHORD  ( -- )
    }arpeg
;

: VALUE{ ( -- )
    ns-leave-value on
;
: }VALUE ( -- )
    ns-leave-value off
;

SES_USE_VOCAB [IF]
previous definitions
[THEN]

