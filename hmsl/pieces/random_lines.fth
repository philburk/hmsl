ANEW TASK-RANDOM_LINES

\ Draw random lines in different colors.
\ This will run as fast as possible and use 100% of CPU time.

: DRAW.RAND  ( -- , draw a random vector )
    8 choose gr.color!  ( set random color )
    600 choose   ( generate random x ) 
    400 choose   ( generate random y ) 
    gr.draw      ( draw line ) 
; 

: MANY.RAND ( -- , draw many random vectors ) 
    hmsl.open
    BEGIN
        draw.rand 
        ?closebox   ( has closebox been hit ) 
    UNTIL 
    hmsl.close
; 

." To see random lines drawn, enter:  MANY.RAND" cr
