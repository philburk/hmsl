\ variables and constants for b'rey'sheet

anew task-b_variables

v: prev-lpitch \ for debouncing adc for local sound
v: prev-fpitch \ for fb
v: last-lpitch \ for pitch change -- chorales
v: curr-lpitch \ current pitch local from singer
v: curr-fpitch \ fb pitch
v: curr-ffpitch \ fb fine pitch offset
v: curr-algorithm \ current dep-5 algorithm
v: prev-wst \ time, for deciding on waveform changing
v: prev-dep \ time for deciding on dep-5 changing
v: var-# \ where in piece
v: change-note 
v: change-note-range
v: local.pitch-prev
v: temp-adc-index
v: last-adc-value
v: temp-wst \ current waveform being transformed
v: adc-debounce

\ fill these arrays with absolute pitches for instruments
ob.array local.pitch.array
ob.array f.pitch.array
ob.array ff.pitch.array
ob.array adc.array


: build.pitch.arrays
	9 new: local.pitch.array
	9 new: f.pitch.array
	9 new: ff.pitch.array	
	9 new: adc.array
;

: free.pitch.arrays
	free: local.pitch.array
	free: f.pitch.array
	free: ff.pitch.array
	free: adc.array
;

\ define pitch name constants

\ fb coarse
71 k: f_F#' 
69 k: f_E' 
68 k: f_D# 
65 k: f_C# \ tune up from c natural
64 k: f_B 
62 k: f_A 
61 k: f_G# 
59 k: f_F#
57 k: f_E 

\ fb offsets
33 k: ff_F#' \ 12/7 33 wide
2  k: ff_E'  \ 3/2 2 wide
17 k: ff_D#  \ 10/7 17 wide
86 k: ff_C#  \ 5/4 14 narrow
31 k: ff_B   \ 8/7 31 wide
0  k: ff_A 
19 k: ff_G#  \ 20/21 15 narrow
33 k: ff_F#  \ 6/7 33 wide
2  k: ff_E   \ 2/3 2 wide

\ local amiga scale in just ratios: to alter fundamental, change "a"
\ to alter ratios, change ratios  these ratios have small 
\ arithmetic offsets to tune precisely to  fb-o1

293  k: l_a

l_a 3  * 4  /  1+   k: l_e
l_a 6  * 7  /  1-   k: l_f#
l_a 20 * 21 /       k: l_g#
l_a 8  * 7 /        k: l_b
l_a 5  * 4 /  3 -   k: l_c#
l_a 10 * 7 /        k: l_d#
l_a 3  * 2 /  1 +   k: l_e'
l_a 12 * 7 /  2 -   k: l_f#'

