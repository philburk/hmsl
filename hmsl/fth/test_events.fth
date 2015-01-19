\ Test event generation
\ Author: rnm & Phil Burk

anew task-test_events.fth

WindowTemplate testWindow

: build.window
	" A Test HMSL Window" testWindow ..! wt_Title
	100 testWindow .. wt_Rect ..! rect_top
	100 testWindow .. wt_Rect ..! rect_left
	600 testWindow .. wt_Rect ..! rect_bottom
	700 testWindow .. wt_Rect ..! rect_right
;

: TEV.INIT
\ hostInit()
    build.window
	testWindow gr.openwindow gr-curwindow !
;

: TEV.TERM
	gr.closecurw
;

: TEV.HANDLE.EVENT { event | ifquit -- ifquit , Process one event from event queue. }
    false -> ifquit
    event
    CASE
        EV_NULL OF
\            ." EV_NULL" cr
        ENDOF

        EV_MOUSE_DOWN OF 
            ." mouse DOWN at " gr.getxy swap . . cr
        ENDOF

        EV_MOUSE_UP OF
            ." mouse UP at " gr.getxy swap . . cr
        ENDOF

        EV_MOUSE_MOVE OF
            ." mouse MOVE at " gr.getxy swap . . cr
        ENDOF

        EV_REFRESH OF
            ." EV_REFRESH" cr
        ENDOF

        EV_KEY OF
            ." EV_KEY " ev.get.key dup . emit cr
        ENDOF

        EV_CLOSE_WINDOW OF
            true -> ifquit
        ENDOF
    ENDCASE
    ifquit
;

: TEV  ( -- )
    BEGIN
        ev.get.event ( get one event )
        tev.handle.event
        ?terminal OR
    UNTIL
;

if.forgotten tev.term
