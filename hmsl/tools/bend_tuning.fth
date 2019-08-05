\ tune to arbitrary ratios using Pitch Bend
\
\ Phil Burk

decimal
include? fpinit hsys:FloatingPoint

anew TASK-BEND_TUNING

fpinit

2.0 fln fconstant fln_2

\ For the purposes of these calculations, 0 pitch bend is consider NO bend
\ In the MIDI spec, $2000 is NO bend.
\ We account for this in the function MIDI.PITCH.BEND

\ calculate pitch bend amount for a N:1 ratio
$ 2000 constant BENDS_PER_SEMITONE
12 constant SEMITONES_PER_OCTAVE
: calc.bend.n { n bend_per_octave -- fbend }
    n s>f fln
    fln_2 f/
    bend_per_octave s>f f*
;

: calc.n>pbend ( n -- pbend )
    BENDS_PER_SEMITONE SEMITONES_PER_OCTAVE *  \ pitch bends per octave
    calc.bend.n
    f>s
;

: gen.bend.table  ( max_n -- )
    cr
    1 max 1
    DO  i calc.n>pbend . ."  ," cr
    LOOP
;

\ 100 gen.bend.table
CREATE BEND-TABLE
here  \ for size calculation
0 , \ actually negative infinity
0  ,
98304  ,
155808  ,
196608  ,
228255  ,
254112  ,
275974  ,
294912  ,
311616  ,
326559  ,
340076  ,
352416  ,
363768  ,
374278  ,
384063  ,
393216  ,
401814  ,
409920  ,
417588  ,
424863  ,
431782  ,
438380  ,
444684  ,
450720  ,
456510  ,
462072  ,
467424  ,
472582  ,
477559  ,
482367  ,
487017  ,
491520  ,
495884  ,
500118  ,
504229  ,
508224  ,
512110  ,
515892  ,
519576  ,
523167  ,
526669  ,
530086  ,
533424  ,
536684  ,
539871  ,
542988  ,
546038  ,
549024  ,
551948  ,
554814  ,
557622  ,
560376  ,
563077  ,
565728  ,
568331  ,
570886  ,
573396  ,
575863  ,
578287  ,
580671  ,
583015  ,
585321  ,
587591  ,
589824  ,
592023  ,
594188  ,
596321  ,
598422  ,
600492  ,
602533  ,
604545  ,
606528  ,
608485  ,
610414  ,
612318  ,
614196  ,
616050  ,
617880  ,
619687  ,
621471  ,
623233  ,
624973  ,
626692  ,
628390  ,
630069  ,
631728  ,
633367  ,
634988  ,
636590  ,
638175  ,
639742  ,
641292  ,
642825  ,
644342  ,
645843  ,
647328  ,
648798  ,
650252  ,
651692  ,
here swap - cell/ constant NUM_BENDS
NUM_BENDS . ." bends in table" cr

: N>PBEND  ( n -- pbend )
    dup NUM_BENDS 1- >
    IF
        ." N>PBEND - N too high = " dup . cr 0
    ELSE
        cell* bend-table + @
    THEN
;

: RATIO>PBEND  { numer denom -- pbend }
    numer n>pbend
    denom n>pbend -
;

: PBEND>NOTE+PB  ( pbend -- note pbend , convert to reasonable note )
    BENDS_PER_SEMITONE /mod swap
;

: NOTE>PBEND ( note -- pbend )
    BENDS_PER_SEMITONE *
;

: PLAY.PBEND  { pbend vel -- }
    pbend pbend>note+pb midi.pitch.bend
    vel midi.noteon
;

: PLAY.RATIO  { numer denom vel -- }
    numer denom ratio>pbend \ convert the ratio to a relative pitch bend
    60 note>pbend +    \ calc pbend of interval from Middle C
    vel play.pbend     \ play interval
;

