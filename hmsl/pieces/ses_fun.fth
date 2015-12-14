\ Experiments with Score Entry System
\ 10/11/90

ANEW TASK-SES_FUN

: POLY  ( -- )
    par{ 1/12 c4 c# d d# e f
        6 0
        DO 12 choose 50 + note
        LOOP
    }par{
        1/8 c5 c c c g g g g
    }par
;

: GLISS  { incr start  #notes -- }
    #notes 0
    DO  ." , " i . start dup .  note
        start incr + -> start
    LOOP cr
;

: CRISSCROSS  ( -- , crossing lines )
    par{
        2 40 16 1/16 gliss
    }par{
        -1 74 32 1/32 gliss
    }par
    1/2 chord{ 40 note 74 note }chord
;

: PHASEM  ( -- , melodies of different length )
    par{  5 0 DO c# d g g# LOOP
    }par{ 4 0 DO e f a f d LOOP
    }par
;

: SPEEDUP ( -- , accelerate )
    1/4
    4 accel{ 
    8 0
    DO  c e f g
    LOOP
    }accel
;

: RIFF1  1/4 c g 1/16 d rest d rest a a b b ;
: RIFF2  1/4 e f 1/8 d d e d ;

: PAR.NEST ( -- )
    par{  1/4 c3 c c c
        par{ 1/16 c4 e f g g g g g
        }par{ 1/16 c3 g3 f d e e e e
        }par
    }par{
        1/4 g5 f e d f6 f f f f f f f
    }par
;

: SPICE  ( -- )
    1/8 30 /\  c c e e 30 /\ d d 40 /\ a a ;
;

: SHOOSH1 ( -- )
    1/16 _fff
    90 7 8 * 16  >>> 8 0 DO  c6 b d g e a f LOOP ns-cur-velocity @ .
    90 7 8 * 16  <<< 8 0 DO  c b d g e a f LOOP
;
: SHOOSH2 ( -- )
    1/16 _ppp
    90 7 8 * 16 <<< 7 0 DO  c3 b d g e a f f LOOP ns-cur-velocity @ .
    90 7 8 * 16 >>> 7 0 DO  c b d g e a f f LOOP
;

: SHOOSH
    par{ shoosh1 }par{ shoosh2 }par
;

: CASE.RIFF  ( N -- , play whatever )
    CASE
    0 OF riff1 ENDOF
    1 OF riff2 ENDOF
    2 OF poly ENDOF
    3 OF crisscross ENDOF
    4 OF speedup ENDOF
    5 OF shoosh ENDOF
    ENDCASE
;

: PLAY.RIFF  ( note vel -- )
    drop 6 mod case.riff
;

: MP.RIFFS ( -- )
    mp.reset
    'c play.riff  mp-on-vector !
    midi.parse.loop
;

: PLAY.LOTS  ( N -- )
    0
    DO i 6 mod case.riff
    LOOP
;

\ Acceleration
: ZAP/3 1/3 c3 c c  c c c ;
: ZAP/4 1/4 g5 g g g  g g g g ;

: PAR.ZAP
    par{
        zap/3 zap/3
    }par{
        zap/4 zap/4
    }par
    1/4 d d d d
;

exists? FLOAT
: DO.ACCEL ( factor numer denom -- )
    par.zap
    faccel{ par.zap }faccel
    par.zap
;
.THEN


    
