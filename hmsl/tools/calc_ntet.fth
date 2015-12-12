\ Calculate frequencies for N Tone Equal Temperament
\
\ Author: Phil Burk
\ Copyright 1991 Phil Burk

include? f* hsys:floatingPoint
fpinit

ANEW TASK-CALC_NTET

\ freq(n,N) = freq(0) * 2.0**(n/N)

: CALC.NTET  { n ntet ifreq0 -- nfreq }
    2.0   n float ntet float f/   f**
    ifreq0 float f*
;

: PRINT.NTET  { ntet ifreq0 -- , prints table }
    >newline ."   i     freq" cr
    ntet 1+ 0
    DO
        i 3 .r 4 spaces
        i ntet ifreq0 calc.ntet
        10 f.r cr
    LOOP
;

: N>DIGITS { n digs -- addr count }
    n s->d
    <#  digs 0
    DO  #
    LOOP
    #s #>
;
    
: DUMP.NTET.HEX  { nlo nhi ntet ifreq0 -- , prints 'C' code }
    base @ >r
    >newline
    nhi 1+ nlo -2sort
    DO
        i ntet ifreq0 calc.ntet
        int \ $ FFFF min
        hex ."     0x" 4 n>digits type
        decimal ." ,  /* " i 2 .r ."  */" cr
    LOOP
    r> base !
;

