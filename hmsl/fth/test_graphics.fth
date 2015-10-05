\ Test basic portable graphics code
\ Author: rnm & Phil Burk

anew task-test_graphics.fth

WindowTemplate testWindow

: build.window
	" A Test HMSL Window" testWindow ..! wt_Title
	100 testWindow .. wt_Rect ..! rect_top
	100 testWindow .. wt_Rect ..! rect_left
	600 testWindow .. wt_Rect ..! rect_bottom
	700 testWindow .. wt_Rect ..! rect_right
;

: TGR.INIT
\ hostInit()
    build.window
	testWindow gr.openwindow gr-curwindow !
;

: TGR.TERM
	gr.closecurw
;

if.forgotten tgr.term

16 constant NUM_COLORS

: random.rects
	1000 0 DO
		NUM_COLORS choose dup . cr gr.color!
		4 0 DO 100 choose LOOP
        .s cr
		gr.rect
	LOOP
;

: TGR.SHOW.COLORS { x0 y0 numColors -- }
    numColors 0 do
        i . cr
        i gr.color!
        i 10 * x0 +
        y0
        over 10 +
        y0 90 +
        gr.rect
    loop
;


: TGR.CHECK.XOR { x0 y0 x1 y1 -- }
    gr_insert_mode gr.mode!
    x0 y0 10 + 
    x1 y1 10 - gr.rect
    
    gr_xor_mode gr.mode!
    x0 10 +  y0
    x1 10 -  y1 gr.rect
    
    x0 20 +  y0 20 +
    x1 20 -  y1 20 - gr.rect
    
    gr_insert_mode gr.mode!
;

: TGR.CROSS.COLORS { x0 y0 numColors xorColor -- }
    x0 20 + y0 numColors tgr.show.colors
    xorColor gr.color!
    gr_xor_mode gr.mode!
    x0 y0 20 +
    over 200 + over 30 + gr.rect
;

: TGR.RECT.LINES  { x0 y0 x1 y1 -- }
    x0 y0 gr.move
    x1 y0 gr.draw
    x1 y1 gr.draw
    x0 y1 gr.draw
    x0 y0 gr.draw
;

: TGR.NESTED  { x0 y0 x1 y1 -- }
    gr_insert_mode gr.mode!
    1 gr.color!
    x0 y0 x1 y1 tgr.rect.lines
    5 gr.color!
    x0 1+ y0 1+ x1 1- y1 1- gr.rect
    2 gr.color!
    x0 2+ y0 2+ x1 2- y1 2- gr.rect
;

: TGR.TEXT.PLACE  { x0 y0 -- }
    1 gr.color!
    x0 y0 10 - gr.move
    x0 20 - y0 20 - gr.draw
    x0 y0 gr.draw
    " hey" gr.text
    x0 100 + y0 100 + gr.draw
;

: TGR
    gr.clear
    20 20 8 0 tgr.cross.colors
    20 120 8 1 tgr.cross.colors
    320 20 8 2 tgr.cross.colors
    320 120 8 3 tgr.cross.colors
\
    100 250 300 350 tgr.nested
    
    350 250 tgr.text.place
;
