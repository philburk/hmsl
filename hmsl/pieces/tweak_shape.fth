\ Play a shape and tweak the notes as we repeat.
\ This requires version 4.2
\
\ Phil Burk, 921207

anew task-tweak_shape

ob.shape ts-shape

: RAND.WHOLE.TONE ( -- note ,  select note using whole tone scale )
    12 choose 2* 48 +
;

\ This word uses a local variable to hold the shape address.
: TWEAK.NOTE { shape -- , tweak note in a shape }
    rand.whole.tone
    many: shape choose \ select random index based on how many in shape
    1 ( -- note index dim=1 )
    ed.to: shape  ( set random note's dimension to a whole tone )
;
    
: TS.INIT  ( -- , put some random notes in a shape and play it )
    32 3 new: ts-shape     \ allocate space in shape
    16 0                   \ loop 16 times
    DO  2 choose 1+ 10 *   \ set duration to 10 or 20
        rand.whole.tone    \ select note using whole tone scale
        70                 \ set velocity to 70
        add: ts-shape      \ add those 3 values to ts-shape
    LOOP
\
\ specify a function to be executed when the shape repeats
    'c tweak.note put.repeat.function: ts-shape
\ specify the number of times to repeat
    8 put.repeat: ts-shape
;

: TS.TERM
    free: ts-shape
;

\ When HMSL is started many morphs can play simultaneously
\ in a hierarchy or independantly.
: TS.PLAY
    ts.init
    ts-shape hmsl.edit.play  \ start hmsl and play ts-shape in the background
    ts.term
;

." TS.PLAY" cr

