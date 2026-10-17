\ waveform changing actions, and modulators

anew task-simple_waves

: change.wave1 if 256 choose 128 - 256 choose 8bit-wave + c! then ;
: change.wave2 if 256 choose 128 - 32 choose 5bit-wave + c! then ;
: change.wave3 if 256 choose 128 - 8 choose 3bit-wave + c! then ;
: change.wave4 if 256 choose 128 - 64 choose 6bit-wave + c! then ;

: af.on da.channel! 1 da.freqmod! 1 da.ampmod! ;
: af.off da.channel! 0 da.freqmod! 0 da.ampmod! ;

: am.on.0 0 af.on ;
: am.off.0 0 af.off ;

: fm.on.1 1 af.on ;
: fm.off.1 1 af.off ;


: am.on.2 2 af.on ;
: am.off.2 2 af.off ;

: fm.on.3 3 af.on ;
: fm.off.3 3 af.off ;
