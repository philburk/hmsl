\ twlm variables

anew task-wlm_variables

\ the following variable is for compiling the piece slightly differently
\ if it is going to be turnkeyed
v: wlm-turnkey
true wlm-turnkey !


\ wlm-list is just an object list
OB.OBJLIST WLM-LIST
OB.JOB WLM-LIST-JOB

\ this constant sets how many wlm's you want to use
\ for the screen and for the piece. it is used by the file
\ WLM_SCREEN quite often. For a smaller version of the piece, perhaps
\ to help it fit on smaller screens, change this value...
16 k: #-channels

\ this is a simple patch to setup the screen for a preset that you like...
1 k: default_preset

\ the following constant was put into wlm_list instead (defined earlier), so that the
\ list could use it as well...
\ 16  k: #-channels ( this could be reset to make a smaller, say, 8 channel version )

\ these values are used by the harm. function to set the fundamental by which the 16 channel
\ pitches are computed, and the basic value by which durations are divided in the RATIO
\ feature
\ n.b the duration number does not divide evenly by 7, 11, 13 and so on, but it would get
\ TOO big... so the higher numbers will be divisible approximations...
\ this number is an E natural, which is the series i tuned for the piece at mobius, in
\ january, 1993
40 value harm-series-fund
2 2 3 3 7 5  * * * * * value duration-fund
ob.array harm-series-array

\ this variable turns on or off fundamental tracking for harmonic and ratio features
v: fundamental-tracking?
false fundamental-tracking? !

\ variables for jitter for screen moving of global parameters
v: pitch-jitter
v: dur-jitter
v: loudness-jitter
v: control-jitter
v: staccato-jitter
v: staccatp-jitter
v: pitch-inc-jitter
v: dur-inc-jitter
v: loudness-inc-jitter
v: control-inc-jitter

\ screen and grid declarations

ob.screen wlm-screen

\ individual voices
ob.check.grid wlm-on
ob.numeric.grid wlm-channel
ob.numeric.grid wlm-dur
ob.numeric.grid wlm-dur-prob
ob.numeric.grid wlm-pitch-prob
ob.numeric.grid wlm-loudness-prob
ob.numeric.grid wlm-pitch-inc
ob.numeric.grid wlm-dur-inc
ob.numeric.grid wlm-loudness-inc
ob.check.grid wlm-dur-on
ob.check.grid wlm-pitch-on
ob.check.grid wlm-loudness-on
ob.numeric.grid wlm-pitch
ob.numeric.grid wlm-loudness
ob.numeric.grid wlm-staccato
\
\ individual voices
ob.numeric.grid wlm-control
ob.numeric.grid wlm-control-prob
ob.numeric.grid wlm-control-inc
ob.check.grid wlm-control-on
ob.numeric.grid wlm-control-#
ob.numeric.grid wlm-preset-#
\
\ global ones
ob.check.grid wlm-ons
ob.check.grid wlm-dur-ons
ob.check.grid wlm-pitch-ons
ob.check.grid wlm-loudness-ons
ob.check.grid wlm-control-ons
ob.numeric.grid wlm-controls
ob.numeric.grid wlm-control-probs
ob.numeric.grid wlm-control-incs
ob.numeric.grid wlm-presets-#
ob.numeric.grid wlm-controls-#
ob.numeric.grid wlm-dur-incs
ob.numeric.grid wlm-pitch-incs
ob.numeric.grid wlm-channels
ob.numeric.grid wlm-durs
ob.numeric.grid wlm-dur-probs
ob.numeric.grid wlm-pitch-probs
ob.numeric.grid wlm-loudness-probs
ob.numeric.grid wlm-loudness-incs
ob.numeric.grid wlm-pitches
ob.numeric.grid wlm-loudnesses
ob.numeric.grid wlm-staccatos
\ jitter globals
ob.numeric.grid wlm-pitch-jitter
ob.numeric.grid wlm-loudness-jitter
ob.numeric.grid wlm-dur-jitter
ob.numeric.grid wlm-control-jitter
ob.numeric.grid wlm-staccato-jitter
\ increment jitters
ob.numeric.grid wlm-loudness-inc-jitter
ob.numeric.grid wlm-dur-inc-jitter
ob.numeric.grid wlm-pitch-inc-jitter
ob.numeric.grid wlm-control-inc-jitter
\
ob.check.grid wlm-functions
ob.numeric.grid wlm-tempo
ob.numeric.grid wlm-harm-series-fund
ob.numeric.grid wlm-duration-fund
ob.check.grid wlm-fund-track
\
ob.numeric.grid wlm-pitch-range
ob.numeric.grid wlm-loudness-range
ob.numeric.grid wlm-duration-range
ob.numeric.grid wlm-control-range
\ globals
ob.numeric.grid wlm-pitch-ranges
ob.numeric.grid wlm-loudness-ranges
ob.numeric.grid wlm-duration-ranges
ob.numeric.grid wlm-control-ranges
\
ob.numeric.grid cg-time-advance

