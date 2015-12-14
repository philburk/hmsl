\ Scaled graphics for drawing shapes, etc.
\ This is loosely based on the GKS Window and Viewport concept. 
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 6/30/86 Added scg.delta.wc->dc , sc.dc->wc
\ MOD: PLB 9/30/86 Changed viewport in scg.test to Y=50,150
\                  Use -ROT
\ MOD: PLB 10/9/86 Converted */ to * scg_scale ashift ( 5Xfaster!)
\ MOD: PLB 12/15/86 Expand viewport rectangle in SHOW
\ MOD: PLB 5/24/87 Add SYS.INIT
\ MOD: PLB 1/26/88 Draw more spaces in SCG.DRAW.XAXIS and YAXIS to
\                  cover old big numbers.
\ MOD: PLB 2/8/88  Switch sense of Y axis to put 0,0 in TOP,left.
\ MOD: PLB 10/27/89 Add SCG.BOX
\ MOD: PLB 10/31/90 Add rounding for better precision.

ANEW TASK-SCG

\ Fixed point shift scale factor.
-10 CONSTANT SCG_SCALE  ( negative to optimize wc->dc )
4096 constant SCG_DEFAULT_WC

( Arrays for holding Window Viewport definitions )
OB.ELMNTS SCG-WINDOWS
OB.ELMNTS SCG-VIEWPORTS
8 CONSTANT SCG-MAXTNR   ( Maximum # normalization transforms)

V: SCG-VALID-TNR  ( valid calculated TNR )
V: SCG-CTNR ( Current Transformation )

( Current transformation factors, quick calculation. )
V: SCG-XMULT  V: SCG-XADD
V: SCG-YMULT  V: SCG-YADD

\ Set and query window and viewport like GKS
: SCG.SWN ( wxmin wxmax wymin wymax tnr -- , set window )
    put: scg-windows
    -1 scg-valid-tnr !
;
: SCG.SVP ( vxmin vxmax vymin vymax tnr -- , set viewport )
    put: scg-viewports
    -1 scg-valid-tnr !
;

: SCG.QWN ( tnr -- wxmin wxmax wymin wymax , set window )
    get: scg-windows
;
: SCG.QVP ( tnr -- vxmin vxmax vymin vymax , set viewport )
    get: scg-viewports
;

V: SCG-WMIN V: SCG-WMAX V: SCG-VMIN V: SCG-VMAX

( Calculate A & B for Ax + B transform )
: SCG.CALCXF ( <above variables> -- mult adder )
    scg-vmax @ scg-vmin @ - scg_scale negate ashift
    scg-wmax @ scg-wmin @ - /   ( mult )
    dup scg-wmin @ * scg_scale ashift
    scg-vmin @ swap -  ( adder )
;

: (SCG.SELNT)  ( tnr -- , Select Normalization Transform )
    dup scg-ctnr !
    dup get: scg-windows 2drop scg-wmax ! scg-wmin !
    dup get: scg-viewports 2drop scg-vmax ! scg-vmin !
    scg.calcxf scg-xadd ! scg-xmult !
\
    dup get: scg-windows scg-wmax ! scg-wmin ! 2drop
    get: scg-viewports scg-vmax ! scg-vmin ! 2drop
    scg.calcxf scg-yadd !    scg-ymult !
;

: SCG.SELNT  ( tnr -- , recalculate if not valid )
    dup scg-valid-tnr @ =
    IF drop  ( already calculated )
    ELSE dup (scg.selnt) scg-valid-tnr !
    THEN
;
    
: SCG.TNR@ ( -- tnr , Query Transformation number )
     scg-ctnr @
;

\ Coordinate conversions
: SCG.WC->DC ( WCX WCY -- DCX DCY , Convert world to device)
      scg-ymult @ *
      [ 1 scg_scale negate 1- ashift ] literal + ( round )
      scg_scale ashift
      scg-yadd @ + >r
      scg-xmult @ *
      [ 1 scg_scale negate 1- ashift ] literal + ( round )
      scg_scale ashift
      scg-xadd @ + r>
;

: SCG.DELTA.WC->DC ( dWCX dWCY -- dDCX dDCY , Convert delta coordinates)
      scg-ymult @ *
      [ 1 scg_scale negate 1- ashift ] literal + ( round )
      scg_scale ashift >r
      scg-xmult @ *
      [ 1 scg_scale negate 1- ashift ] literal + ( round )
      scg_scale ashift r>
;

: SCG.DC->WC ( DCX DCY -- WCX WCY , Convert device to world)
      scg-yadd @ -
      [ scg_scale negate ] literal ashift
      scg-ymult @ dup>r 2/ + ( round ) r> / 
      swap scg-xadd @ -
      [ scg_scale negate ] literal ashift
      scg-xmult @ dup>r 2/ + ( round ) r> / swap
;

: SCG.DELTA.DC->WC ( dDCX dDCY -- dWCX dWCY , Convert delta coordinates)
      [ scg_scale negate ] literal ashift
      scg-ymult @ dup>r 2/ + ( round ) r> / 
      swap [ scg_scale negate ] literal ashift
      scg-xmult @ dup>r 2/ + ( round ) r> / swap
;

: SCG.SHOWVP  ( tnr -- , draw box around viewport )
     get: scg-viewports rot swap
     1+ >r 1+ >r 1- >r 1-   r> r> r>  ( expand out by one pixel )
     ug.box
;

\ Scaled Graphics Drawing Primitives
: SCG.MOVE ( wcx wcy -- , move )
     scg.wc->dc gr.move
;

: SCG.DRAW ( wcx wcy -- , draw )
     scg.wc->dc gr.draw
;

: SCG.XYTEXT ( xwc ywc text -- , Draw text at x,y)
    -rot scg.move
    gr.text
;

: SCG.RECT { xw1 yw1 xw2 yw2 -- , Fill world region with FACI }
    xw1 yw1 scg.wc->dc -> yw1 -> xw1
    xw2 yw2 scg.wc->dc -> yw2 -> xw2
    xw1 xw2 2sort -> xw2 -> xw1
    yw1 yw2 2sort -> yw2 -> yw1  ( prevent big crash )
    xw1 yw1 xw2 yw2 gr.rect
;

: SCG.BOX  ( xw1 yw1 xw2 yw2 -- )
    scg.wc->dc 2swap scg.wc->dc ug.box
;

\ Control and Initialization
: SCG.INIT ( -- , Set initial Viewports )
     -1 scg-valid-tnr !
     scg-maxtnr 4 new: scg-windows
     scg-maxtnr 4 new: scg-viewports
     scg-maxtnr dup set.many: scg-windows  set.many: scg-viewports
     scg-maxtnr 0
     ?DO \ Set all transforms
         0 scg_default_wc 0 scg_default_wc i SCG.SWN
         gr_xmin gr_xmax  gr_ymin gr_ymax i scg.svp
         i scg.selnt
     LOOP
;

: SCG.TERM ( -- , Terminate this system )
    free: scg-windows
    free: scg-viewports
;

: SCG.NUM.RIGHT  { x y n -- , draw right justified }
     x n n>text gr.textlen -
     "  " count gr.textlen - y gr.move
     "  " gr.text n gr.number
;

\ Label corners of a viewport with WC values
: SCG.DRAW.XAXIS
    scg.tnr@ 0 ed.at: scg-viewports
    scg.tnr@ 2 ed.at: scg-viewports
    scg.tnr@ 3 ed.at: scg-viewports MAX
    gr.height@ + 2+ gr.move
    scg.tnr@ 0 ed.at: scg-windows gr.number  ( X MIN )
    "     " gr.text
\
    scg.tnr@ 1 ed.at: scg-viewports
    scg.tnr@ 2 ed.at: scg-viewports
    scg.tnr@ 3 ed.at: scg-viewports MAX
    gr.height@ + 2+ ( -- x y )
    scg.tnr@ 1 ed.at: scg-windows
    scg.num.right
;

: SCG.DRAW.YAXIS ( -- , put on left of viewport )
    scg.tnr@ 0 ed.at: scg-viewports 4 -
    scg.tnr@ 2 ed.at: scg-viewports 10 +
    scg.tnr@ 2 ed.at: scg-windows  ( YMIN )
    scg.num.right
\
    scg.tnr@ 0 ed.at: scg-viewports 4 -
    scg.tnr@ 3 ed.at: scg-viewports
    scg.tnr@ 3 ed.at: scg-windows ( Y MAX )
    scg.num.right  
;

: SCG.DRAW.AXES
    scg.draw.xaxis
    scg.draw.yaxis
;

: SYS.INIT sys.init scg.init ;
: SYS.TERM scg.term sys.term ;

\ Test SCG routines ------------------------------------
if-testing @ [IF]
: SCG.FIG1 ( -- draw a figure )
      0 0 SCG.MOVE   2000 2000 SCG.DRAW
      1800 1300 SCG.DRAW    300 700 SCG.DRAW
      0 0 SCG.DRAW
;
: SCG.TESTNTS ( -- , Set test NTs )
      0 2000 0 2000 0 SCG.SWN   0 200 0 200 0 SCG.SVP
      0 2000 0 2000 1 SCG.SWN   200 500 50 150 1 SCG.SVP
;
: SCG.TEST1   ( -- , Test drawing )
      SCG.TESTNTS
      0 SCG.SELNT 0 SCG.SHOWVP SCG.FIG1
      1 SCG.SELNT 1 SCG.SHOWVP SCG.FIG1
;
[THEN]

