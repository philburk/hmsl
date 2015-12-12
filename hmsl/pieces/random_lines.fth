ANEW TASK-RANDOM_LINES

: DRAW.RAND  ( -- , draw a random vector )
    8 choose gr.color!  ( set random color )
    400 choose   ( generate random x ) 
    200 choose   ( generate random y ) 
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

." MANY.RAND" cr
