\ Draw gadgets using 3D style rectangles.

ANEW TASK-BEVEL

2 value color_lit
3 value color_shaded

: DRAW.BEVEL { x1 y1 x2 y2 down? -- }
    gr.color@ >r
    down? IF color_shaded ELSE color_lit THEN gr.color!
    x1 y2 gr.move
    x1 y1 gr.draw x2 y1 gr.draw
\
    down? IF color_lit ELSE color_shaded THEN gr.color!
    x2 y2 gr.draw x1 y2 gr.draw
    r> gr.color!
;

: DRAW.THICK.BEVEL { x1 y1 x2 y2 down? thickness -- }
    thickness 0
    ?DO
        x1 i + y1 i +
        x2 i - y2 i -
        down? draw.bevel
    LOOP
;

