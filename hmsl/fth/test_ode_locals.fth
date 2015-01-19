\ Test ODE with local variables.

anew task-test_ode_locals.fth

METHOD  TEST.SUM:

:CLASS  OB.TEST.LOCALS  <SUPER  OBJECT
	
	iv.long   tl-data
	
:M   TEST.SUM:  {  lv1  lv2  |  sum   --  }
	>newline
	." lv1 = " lv1 . cr
	." lv2 = " lv2 . cr
	lv1 lv2  + -> sum
	." sum = " sum . cr
	sum iv=> tl-data
;M


:M PRINT:
	." tl-data = " tl-data . cr
;M

;CLASS


ob.test.locals   tl-1

: test.method.locs  ( --- )
	4  5  test.sum: tl-1
	print: tl-1
;

: (test.loc.binding)  { lv1 lv2  tlobj  --  }
	cr
	." Old style late binding ---" cr
	lv1 lv2 tlobj   test.sum: []
	tlobj print: []
	." Local binding ---" cr
	lv1 lv2  test.sum: tlobj
	print: tlobj
;

: test.loc.binding  ( -- )
	6 7 tl-1  (test.loc.binding)
;

