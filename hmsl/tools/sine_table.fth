\ Provide sine and cosine functions in integer fixed point
\ form for speedy fixed point calculation.
\
\ Angles are expressed in Fixed Point Values from 0 to 4, ie.
\   $     0 = 0 degrees
\   $ 10000 = 90 degrees
\   $ 20000 = 180 degrees
\   $ 30000 = 270 degrees
\   $ 40000 = 360 degrees or 0
\
\ The returned sine and cosine values are scaled by 2**16,
\ Thus the sine of 90 degrees is 1.0 or 65,536.
\
\ Author Phil Burk
\ Copyright 1987 - Phil Burk
\
\ MOD: PLB 11/11/87 Fixed odd offset problem in ISIN

ANEW TASK-SINE_TABLE


create SINE-TABLE    ( table of fixed point values)
0 w, 402 w, 804 w, 1206 w, 1608 w, 2010 w, 2412 w, 
2814 w, 3215 w, 3617 w, 4018 w, 4420 w, 4821 w, 5222 w, 
5622 w, 6023 w, 6423 w, 6823 w, 7223 w, 7623 w, 8022 w, 
8421 w, 8819 w, 9218 w, 9616 w, 10013 w, 10410 w, 10807 w, 
11204 w, 11600 w, 11995 w, 12390 w, 12785 w, 13179 w, 13573 w, 
13966 w, 14359 w, 14751 w, 15142 w, 15533 w, 15923 w, 16313 w, 
16702 w, 17091 w, 17479 w, 17866 w, 18253 w, 18638 w, 19024 w, 
19408 w, 19792 w, 20175 w, 20557 w, 20938 w, 21319 w, 21699 w, 
22078 w, 22456 w, 22833 w, 23210 w, 23586 w, 23960 w, 24334 w, 
24707 w, 25079 w, 25450 w, 25820 w, 26189 w, 26557 w, 26925 w, 
27291 w, 27656 w, 28020 w, 28383 w, 28745 w, 29105 w, 29465 w, 
29824 w, 30181 w, 30538 w, 30893 w, 31247 w, 31600 w, 31952 w, 
32302 w, 32651 w, 32999 w, 33346 w, 33692 w, 34036 w, 34379 w, 
34721 w, 35061 w, 35400 w, 35738 w, 36074 w, 36409 w, 36743 w, 
37075 w, 37406 w, 37736 w, 38064 w, 38390 w, 38716 w, 39039 w, 
39362 w, 39682 w, 40002 w, 40319 w, 40636 w, 40950 w, 41263 w, 
41575 w, 41885 w, 42194 w, 42501 w, 42806 w, 43110 w, 43412 w, 
43712 w, 44011 w, 44308 w, 44603 w, 44897 w, 45189 w, 45480 w, 
45768 w, 46055 w, 46340 w, 46624 w, 46906 w, 47186 w, 47464 w, 
47740 w, 48015 w, 48288 w, 48558 w, 48828 w, 49095 w, 49360 w, 
49624 w, 49886 w, 50146 w, 50403 w, 50660 w, 50914 w, 51166 w, 
51416 w, 51665 w, 51911 w, 52155 w, 52398 w, 52639 w, 52877 w, 
53114 w, 53348 w, 53581 w, 53811 w, 54040 w, 54266 w, 54491 w, 
54713 w, 54933 w, 55152 w, 55368 w, 55582 w, 55794 w, 56004 w, 
56212 w, 56417 w, 56621 w, 56822 w, 57022 w, 57219 w, 57414 w, 
57606 w, 57797 w, 57986 w, 58172 w, 58356 w, 58538 w, 58718 w, 
58895 w, 59070 w, 59243 w, 59414 w, 59583 w, 59749 w, 59913 w, 
60075 w, 60235 w, 60392 w, 60547 w, 60700 w, 60850 w, 60998 w, 
61144 w, 61288 w, 61429 w, 61568 w, 61705 w, 61839 w, 61971 w, 
62100 w, 62228 w, 62353 w, 62475 w, 62596 w, 62714 w, 62829 w, 
62942 w, 63053 w, 63162 w, 63268 w, 63371 w, 63473 w, 63571 w, 
63668 w, 63762 w, 63854 w, 63943 w, 64030 w, 64115 w, 64197 w, 
64276 w, 64353 w, 64428 w, 64501 w, 64571 w, 64638 w, 64703 w, 
64766 w, 64826 w, 64884 w, 64939 w, 64992 w, 65043 w, 65091 w, 
65136 w, 65179 w, 65220 w, 65258 w, 65294 w, 65327 w, 65358 w, 
65386 w, 65412 w, 65436 w, 65457 w, 65475 w, 65491 w, 65505 w, 
65516 w, 65524 w, 65531 w, 65534 w, 65536 w,

\ Constants used for fetching from table.
16 constant TRIG_SHIFT
256 constant TRIG_NUM/QUAD
1 trig_shift ashift 1- constant TRIG_FRACT_MASK
3 trig_shift ashift constant TRIG_QUAD_MASK

: ISIN ( angle[0-4] -- sine , does not interpolate )
    dup trig_quad_mask and
    trig_shift negate ashift
    >r  ( save quadrant info )
    trig_fract_mask and
    ( trig_num/quad / 2* )   -8 ashift 2*  ( make sure even index!)
    r@ 1 and
    IF [ trig_num/quad 2* 2- ] literal swap -
    THEN
    sine-table + w@
    r> 2 and
    IF negate
    THEN
;

: ICOS ( angle[0-4] -- cosine )
    $ 10000 + isin
;

decimal
false .IF
: TEST.SINE
    gr.check
    gr.clear
    50 80 gr.move
    256 0
    DO  i 2* 50 +  ( -- x )
        $ 40000 256 / i * isin 1024 / 80 +
        gr.draw
    LOOP
;

: BENCH.SINE.FAST  ( N -- )
    0 DO
        $ 02000 isin drop
    LOOP
;

: BENCH.SINE.SLOW  ( N -- )
    0 DO
        $ 32000 isin drop
    LOOP
;

.THEN
