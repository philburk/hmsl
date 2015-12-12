\ MIDI File Standard Support
\
\ This code allows the sharing of music data between applications.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk
\
\ MOD: PLB 6/11/90 Added SWAP to $MF.LOAD.SHAPE
\ MOD: PLB 10/23/90 Added $MF.OPEN.VR
\ MOD: PLB 6/91 Add MIDIFILE1{
\ 00001 PLB 9/5/91 Fix MIDIFILE1{ by c/i/j/
\ 00002 PLB 3/17/92 Changed MF.WRITE.REL.SHAPE to make notes legato
\       for notation programs.  Add $SAVE.REL.SHAPE and $..ABS..

ANEW TASK-MIDIFILE
decimal

\ Variable Length Number Conversion
variable VLN-PAD  ( accumulator for variable length number )
variable VLN-COUNT  ( number of bytes )

: BYTE>VLN  ( byte -- , add byte to VLN buffer )
    vln-count @ 0>
    IF $ 80 or     ( set continuation bit )
    THEN
    vln-pad 4+ vln-count @ 1+ dup vln-count !
    - c!
;

: NUMBER->VLN  ( N -- address count , convert )
    dup $ 0FFFFFFF >
    IF ." NUMBER->VL - Number too big for MIDI File! = "
       dup .hex cr
       $ 0FFFFFFF and
    THEN
    dup 0<
    IF ." NUMBER->VL - Negative length or time! = "
       dup .hex cr
       drop 0
    THEN
    vln-count off
    BEGIN dup $ 7F and byte>vln
        -7 shift dup 0=
    UNTIL drop
    vln-pad 4+ vln-count @ dup>r - r>
;

: VLN.CLEAR ( -- , clear for read )
    vln-count off vln-pad off
;

: VLN.ACCUM  ( byte -- accumulate another byte )
    $ 7F and
    vln-pad @ 7 shift or vln-pad !
;

\ -------------------------------------------------
variable MF-BYTESLEFT
variable MF-EVENT-TIME
variable MF-#DATA

: CHKID ( <chkid> <name> -- , define chkid )
    32 lword count drop be@ constant
;

chkid MThd 'MThd'
chkid MTrk 'MTrk'

variable mf-FILEID
16 constant MF_PAD_SIZE
variable mf-PAD mf_pad_size allot

DEFER MF.PROCESS.TRACK   ( size track# -- )
DEFER MF.ERROR

' abort is mf.error

: .CHKID ( 'chkid' -- , print chunk id )
    pad be! pad 4 type
;

: $MF.OPEN  ( $filename -- )
    dup c@ 0=
    IF drop ." $MF.OPEN - No filename given!" cr mf.error
    THEN
    dup count  r/o bin open-file
    IF drop ." Couldn't open file: " $type cr mf.error
    THEN
    mf-fileid !
    drop
;

: $MF.CREATE  ( $filename -- , create new file )
    dup c@ 0=
    IF drop ." $MF.OPEN - No filename given!" cr mf.error
    THEN
    dup count w/o bin create-file
    IF drop ." Couldn't create file: " $type cr mf.error
    THEN
    mf-fileid !
    drop
;
: MF.SET.FILE  ( fileid -- )
    mf-fileid !
;

: MF.READ ( addr #bytes -- #bytes , read from open mf file)
    dup negate mf-bytesleft +!
    mf-fileid @ read-file abort" Could not read MIDI file."
;

: MF.READ.CHKID  ( -- size chkid )
    dup>r mf-pad 8 mf.read
    8 -
    IF ." Truncated chunk " r@ .chkid cr mf.error
    THEN
    rdrop
    mf-pad cell+ be@
    mf-pad be@
;


: MF.WRITE ( addr #bytes -- #bytes , write to open mf file)
    dup>r mf-fileid @ write-file abort" Could not write MIDI file."
    r>
;

: MF.WRITE? ( addr #bytes -- , write to open mf file or mf.ERROR)
    mf-fileid @ write-file abort" Could not write MIDI file."
;

: MF.READ.BYTE ( -- byte )
    mf-pad 1 mf.read 1-
    IF ." MF.READ.BYTE - Unexpected EOF!" cr mf.error
    THEN
    mf-pad c@
;

: MF.WRITE.BYTE ( byte -- )
    mf-pad c! mf-pad 1 mf.write?
;

: MF.WRITE.WORD ( 16word -- )
    mf-pad w! mf-pad 2 mf.write?
;

: MF.READ.WORD ( -- 16word )
    mf-pad 2 mf.read 2-
    IF ." MF.READ.WORD - Unexpected EOF!" cr mf.error
    THEN
    mf-pad w@
;

: MF.WRITE.CHKID  ( size chkid -- , write chunk header )
    mf-pad be!
    mf-pad cell+ be!
    mf-pad 8 mf.write?
;

: MF.WRITE.CHUNK  ( address size chkid -- , write complete chunk )
    over >r mf.write.chkid
    r> mf.write?
;

: MF.READ.TYPE  ( -- typeid )
    mf-pad 4 mf.read
    4 -
    IF ." Truncated type!" cr mf.error
    THEN
    mf-pad be@
;

: MF.WHERE ( -- current_pos , in file )
    mf-fileid @ file-position abort" file-position failed"
;

: MF.SEEK ( position -- , in file )
    mf-fileid @ reposition-file abort" reposition-file failed"
;

: MF.SKIP  ( n -- , skip n bytes in file )
    dup negate mf-bytesleft +!
    mf.where + mf.seek
;

: MF.CLOSE
    mf-fileid @ ?dup
    IF  close-file abort" close-file failed"
        0 mf-fileid !
    THEN
;

variable MF-NTRKS    \ number of tracks in file
variable MF-FORMAT   \ file format = 0 | 1 | 2
variable MF-DIVISION \ packed division

: MF.PROCESS.HEADER  ( size -- )
    dup mf_pad_size >
    IF ." MF.PROCESS.HEADER - Bad Header Size = "
       dup . cr mf.error
    THEN
    mf-pad swap mf.read drop
    mf-pad bew@ mf-format w!
    mf-pad 2+ bew@ mf-ntrks !
    mf-pad 4+ bew@ mf-division !
;

: MF.SCAN.HEADER ( -- , read header )
    mf.read.chkid  ( -- size chkid)
    'MThd' =
    IF mf.process.header
    ELSE ." MF.SCAN - Headerless MIDIFile!" cr mf.error
    THEN
;

: MF.SCAN.TRACKS ( -- , read tracks )
\ This word leaves the file position just after the chunk data.
    mf-ntrks @ 0
    DO mf.read.chkid 'MTrk' =
       IF dup mf.where + >r
          i mf.process.track
          r> mf.seek ( move past chunk)
       ELSE ." MF.SCAN - Unexpected CHKID!" cr mf.error
       THEN
    LOOP
;

: MF.SCAN ( -- , read header then tracks)
    mf.scan.header
    mf.scan.tracks
;

: MF.VALIDATE ( -- ok? , make sure open file has header chunk )
    mf.where
    0 mf.seek
    mf.read.type 'MThd' =
    swap mf.seek
;

: (MF.DOFILE) ( -- ,process current file )
    mf.validate
    IF  mf.scan
    ELSE ."  Not a MIDIFile!" cr
        mf.close mf.error
    THEN
    mf.close
;

: $MF.DOFILE ( $filename -- , process file using deferred words)
    $mf.open (mf.dofile)
;

: FILEWORD  ( -- addr , parse name with quote delimiters)
    bl lword
    dup 1+ c@ ascii " =  ( is first char a " )
    IF ( -- addr , reset >in and reparse )
        c@ negate >in +!
        ascii " lword
    THEN
;

: MF.DOFILE ( <filename> -- )
    fileword $mf.dofile
;

: MF.READ.VLN ( -- vln , read vln from file )
    vln.clear
    BEGIN mf.read.byte dup $ 80 and
    WHILE vln.accum
    REPEAT vln.accum
    vln-pad @
;

defer MF.PROCESS.META  ( size metaID -- , process Meta event )
defer MF.PROCESS.SYSEX
defer MF.PROCESS.ESCAPE

variable MF-SEQUENCE#
variable MF-CHANNEL
: MF.LOOK.TEXT ( size metaID -- , read and show text )
    >newline ." MetaEvent = " . cr
    pad swap mf.read
    pad swap type cr
;

: MF.HANDLE.META  ( size MetaID -- default Meta event handler )
    dup $ 01 $ 0f within?
    IF mf.look.text
    ELSE CASE
        $ 00 OF drop mf.read.word mf-sequence# ! ENDOF
        $ 20 OF drop mf.read.byte 1+ mf-channel ! ENDOF
          ." MetaEvent = " dup . cr
          swap mf.skip  ( skip over other event types )
        ENDCASE
    THEN
;

' mf.handle.meta is MF.PROCESS.META
' mf.skip is MF.PROCESS.SYSEX
' mf.skip is MF.PROCESS.ESCAPE

: MF.PARSE.EVENT ( -- , parse MIDI event )
    mf.read.byte dup $ 80 and  ( is it a command or running status data )
    IF CASE
        $ FF OF mf.read.byte  ( get type )
                mf.read.vln ( get size ) swap mf.process.meta ENDOF
        $ F0 OF ." F0 byte" cr mf.read.vln mf.process.sysex ENDOF
        $ F7 OF ." F7 byte" cr mf.read.vln mf.process.escape ENDOF
\ Regular command.
    dup mp.#bytes mf-#data !
        dup mp.handle.command
        mf-#data @ 0
        DO mf.read.byte mp.handle.data
        LOOP
       ENDCASE
    ELSE 
        mp.handle.data  ( call MIDI parser with byte read )
        mf-#data @ 1- 0 max 0
        DO mf.read.byte mp.handle.data
        LOOP
    THEN
;

: MF.PARSE.TRACK  ( size track# -- )
    drop mf-bytesleft !
    0 mf-event-time !
    BEGIN mf.read.vln mf-event-time +!
          mf.parse.event
          mf-bytesleft @ 1 <
    UNTIL
;

\ Some Track Handlers
: MF.PRINT.NOTEON ( note velocity -- )
          ?pause
    mf-event-time @ 4 .r ." , "
    ." ON  N,V = " swap . . cr
;
: MF.PRINT.NOTEOFF ( note velocity -- )
          ?pause
    mf-event-time @ 4 .r ." , "
    ." OFF N,V = " swap . . cr
;

: MF.PRINT.TRACK  ( size track# -- )
    2dup
    >newline dup 0=
    IF ." MIDIFile Format = " mf-format @ . cr
       ."        Division = $" mf-division @ dup .hex . cr
    THEN
    ." Track# " . ."  is " . ."  bytes." cr
    'c mf.print.noteon mp-on-vector !
    'c mf.print.noteoff mp-off-vector !
    mf.parse.track
    mp.reset
;

' mf.print.track is mf.process.track

: MF.CHECK ( <filename> -- , print chunks )
    what's mf.process.track
    ' mf.print.track is mf.process.track
    mf.dofile
    is mf.process.track
;

\ Track Handler that loads a shape -----------------------
variable MF-TRACK-CHOSEN
ob.shape MF-SHAPE

: MF.LOAD.NOTEON ( note velocity -- )
    mf-shape ensure.room
    mf-event-time @ -rot add: mf-shape
;

: MF.LOAD.NOTEOFF ( note velocity -- )
    mf-shape ensure.room
    drop mf-event-time @ swap 0 add: mf-shape
;

: MF.LOAD.TRACK ( size track# -- )
    max.elements: mf-shape 0=
    IF 64 3 new: mf-shape
    ELSE clear: mf-shape
    THEN
    'c mf.load.noteon mp-on-vector !
    'c mf.load.noteoff mp-off-vector !
    mf.parse.track
;

: MF.PICK.TRACK  ( size track# -- )
    dup mf-track-chosen @ =
    IF mf.load.track
    ELSE 2drop
    THEN
;

: $MF.LOAD.SHAPE  ( track# $filename -- , load track into mf-shape )
    swap mf-track-chosen !
    what's mf.process.track  SWAP  ( -- oldcfa $filename )
    'c mf.pick.track is mf.process.track
    $mf.dofile
    is mf.process.track
;

: MF.LOAD.SHAPE  ( track# <filename> -- , load track into mf-shape )
    fileword $mf.load.shape
;

: LOAD.ABS.SHAPE  ( shape <filename> -- )
    0 mf.load.shape
    clone: mf-shape
    free: mf-shape
;

\ -------------------------------------------------

\ Tools for writing a MIDIFile.
: MF.WRITE.HEADER  ( format ntrks division -- )
    6 'MThd' mf.write.chkid
    mf-pad 4+ bew!  ( division )
    over 0=
    IF drop 1  ( force NTRKS to 1 for format zero )
    THEN
    mf-pad 2+ bew!  ( ntrks )
    mf-pad    bew!  ( format )
    mf-pad 6 mf.write?
;

: MF.BEGIN.TRACK  ( -- curpos , write track start )
    0 'MTrk' mf.write.chkid
    mf.where
    0 mf-event-time !
;

: MF.WRITE.VLN ( n -- , write variable length quantity )
    number->vln mf.write?
;

: MF.WRITE.TIME ( time -- , write time as vln delta )
    dup mf-event-time @ - mf.write.vln
    mf-event-time !
;

: MF.WRITE.EVENT  ( addr count time -- , write MIDI event )
\ This might be called from custom MIDI.FLUSH
    mf.write.time
    mf.write?
;

variable MF-EVENT-PAD

: MF.WRITE.META  ( addr count event-type -- )
    mf-event-time @ mf.write.time
    $ FF mf.write.byte
    mf.write.byte  ( event type )
    dup mf.write.vln  ( len )
    mf.write?
;

: MF.WRITE.SYSEX  ( addr count -- )
    mf-event-time @ mf.write.time
    $ F0 mf.write.byte
    dup mf.write.vln  ( len )
    mf.write?
;

: MF.WRITE.ESCAPE  ( addr count -- )
    mf-event-time @ mf.write.time
    $ F7 mf.write.byte
    dup mf.write.vln  ( len )
    mf.write?
;

: MF.WRITE.SEQ#  ( seq#  -- )
    mf-event-pad w!
    mf-event-pad 2 0 mf.write.meta
;

: MF.WRITE.END  ( -- , write end of track )
    mf-event-pad 0
    $ 2F mf.write.meta
;

: MF.END.TRACK  ( startpos -- , write length to track beginning )
    mf.where dup>r  ( so we can return )
    over -   ( -- start #bytes )
    swap cell- mf.seek
    mf-pad be! mf-pad 4 mf.write?
    r> mf.seek
;

: MF.CVM+2D ( time d1 d2 cvm -- )
    mf-event-pad c!
    mf-event-pad 2+ c!
    mf-event-pad 1+ c!
    mf-event-pad 3 rot mf.write.event
;

: MF.WRITE.NOTEON ( time note velocity -- )
    $ 90 mf.cvm+2d
;

: MF.WRITE.NOTEOFF ( time note velocity -- )
    $ 80 mf.cvm+2d
;

: $MF.BEGIN.FORMAT0  ( $name -- pos , begin format0 file )
    $mf.create
    0 1 ticks/beat @ mf.write.header
    mf.begin.track  ( startpos )
;

: MF.BEGIN.FORMAT0  ( <name> -- pos , begin format0 file )
    fileword $mf.begin.format0
;

: MF.END.FORMAT0  ( pos -- , end format0 file )
    mf.write.end
    mf.end.track
    mf.close
;

: MF.WRITE.ABS.SHAPE { shape -- , assume shape Nx3+ absolute time }
\ Assume separate note on/off in shape
    shape reset: []
    shape many: [] 0
    DO i 0 shape ed.at: [] ( -- time )
       i 1 shape ed.at: [] ( -- time note )
       i 2 shape ed.at: [] ( -- time note vel )
       dup 0=
       IF mf.write.noteoff
       ELSE mf.write.noteon
       THEN
    LOOP
;

variable MF-SHAPE-TIME

: MF.WRITE.REL.SHAPE { shape | note vel -- , assume shape Nx3 relative time }
    0 mf-shape-time !
    shape reset: []
    shape many: [] 0
    DO
        i 1 shape ed.at: [] -> note ( -- time note )
        i 2 shape ed.at: [] -> vel ( -- time note vel )
        mf-shape-time @ note vel mf.write.noteon
\
\ add to shape time so OFF occurs right before next notes ON 00002
        i 0 shape ed.at: [] ( -- reltime )
        mf-shape-time @ +
        dup mf-shape-time !
        note vel mf.write.noteoff
    LOOP
;

: $SAVE.REL.SHAPE  ( shape $filename -- , complete file output )
\ This word writes out a relative time, 1 event/note shape
\ as note on,off
    $mf.begin.format0
    swap mf.write.rel.shape
    mf.end.format0
;

: $SAVE.ABS.SHAPE  ( shape $filename -- , complete file output )
\ This word writes out a shape as note on,off
    $mf.begin.format0
    swap mf.write.abs.shape
    mf.end.format0
;

: SAVE.REL.SHAPE  ( shape <name> -- , complete file output )
    fileword $save.rel.shape
;

: SAVE.ABS.SHAPE  ( shape <name> -- , complete file output )
    fileword $save.abs.shape
;

: MF.WRITE.TIMESIG  ( nn dd cc bb -- )
    mf-event-pad 3 + c!  ( time sig, numerator )
    mf-event-pad 2+  c!  ( denom log2 )
    mf-event-pad 1+  c!  ( MIDI clocks/metronome click )
    mf-event-pad     c!  ( 32nd notes in 24 clocks )
    mf-event-pad 4 $ 58 mf.write.meta
;
    
: MF.WRITE.TEMPO  ( mics/beat -- )
    mf-event-pad !
    mf-event-pad 1+ 3 $ 51 mf.write.meta
;

\ Capture all MIDI output to a Format0 file
variable MF-START-POS
variable MF-FIRST-WRITE

: (MF.CAPTURED>FILE0)  ( -- write captured MIDI to file format 0)
    0 0 ed.at: captured-midi mf-event-time !
    many: captured-midi 0
    DO i get: captured-midi midi.unpack
       rot mf.write.event
    LOOP
    mf-start-pos @ mf.end.format0
;

: }MIDIFILE0  ( -- )
    if-capturing @
    IF  (mf.captured>file0)
        }capture
    THEN
;

: $CAPTURED>MIDIFILE0  ( $filename -- )
    $mf.begin.format0 mf-start-pos !  ( use filename while still valid )
    (mf.captured>file0)
;

: $MIDIFILE0{  ( $filename -- , start capturing MIDI data )
    }midifile0
    $mf.begin.format0 mf-start-pos !  ( use filename while still valid )
    capture{
;

: MIDIFILE0{ ( <name> -- )
    fileword $midifile0{
;

CREATE MF-COUNT-CAPS 16 allot

: CAP.GET.CHAN  ( status-byte -- channel# )
    $ 0F and 1+
;

: CAP.COUNT.CHANS ( -- #channels , count captured track/channels )
    16 0
    DO 0 i mf-count-caps + c!
    LOOP
\
    many: captured-midi 0
    DO i get: captured-midi midi.unpack drop c@
        cap.get.chan 1-
        nip
        mf-count-caps + 1 swap c!  ( set flag in array )
    LOOP
\
    0
    16 0
    DO i mf-count-caps + c@ +
    LOOP
;

: (MF.CAPTURED>FILE1)  ( -- , write tracks with data to metafile )
    cap.count.chans ( #chans )
    \ write a track zero that should contain tempo maps
    1+ \ for track zero
    mf.begin.track  ( -- pos )
    mf.write.end
    mf.end.track
    \ Write each track with sequence number
    16 0
    DO i mf-count-caps + c@
        IF
            mf.begin.track  ( -- pos )
            0 0 ed.at: captured-midi mf-event-time !
            i 1+ mf.write.seq#
            many: captured-midi 0
            DO
                i get: captured-midi midi.unpack
                over c@ cap.get.chan 1- j  = \ 00001
                IF
                    ( time addr count -- )
                    rot mf.write.event
                ELSE 2drop drop
                THEN
            LOOP
            mf.write.end
            mf.end.track
       THEN
    LOOP
    0 mf.seek
    1 swap ticks/beat @ mf.write.header
    mf.close
;

: }MIDIFILE1  ( -- )
    if-capturing @
    IF  (mf.captured>file1)
        }capture
    THEN
;

: $CAPTURED>MIDIFILE1  ( $filename -- )
    $mf.create
    1 1 ticks/beat @ mf.write.header
    (mf.captured>file1)
;

: $MIDIFILE1{  ( $filename -- , start capturing MIDI data )
    }midifile1
     $mf.create
    1 1 ticks/beat @ mf.write.header
    capture{
;

: MIDIFILE1{ ( <name> -- )
    fileword $midifile1{
;

\ set aliases to format 0 for compatibility with old code
: MIDIFILE{ midifile0{ ;
: $MIDIFILE{ $midifile0{ ;
: }MIDIFILE }midifile0 ;

if.forgotten }midifile0


: tmf
    " testzz5.mid" $midifile0{
    rnow 55 60 midi.noteon
    200 vtime+!
    55 0 midi.noteoff
    }midifile0
;

