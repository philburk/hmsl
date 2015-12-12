\ MIDI File Transfer facility.
\ This allows the transfer of files over MIDI
\ It attempts to conform to the MIDI standard
\ for file transmission.
\ Line feeds and CR are converted to EOL for host
\ if CONVERT-EOL is ON
\
\ USAGE:
\  Use logical volume names to direct files.
\  On the receiving computer, enter:    RECV.FILE
\  On the sending computer, enter:      XMIT.FILE filename
\     
\
\ Files are sent as 7 bit ASCII text disguised as notes.
\
\ Text is sent in packets of 128 bytes on channel 15
\ The first packet contains the filename and is marked preset 125
\ The following packets contain text and is marked 126
\ The End Of File is a Preset 127
\
\ Sequence of transmissions for a packet.
\    Sender            Receiver
\      PRESET 125,126 or 127
\      ON llo lhi                  \ length of packet
\      ON byte0 byte1              \ send text
\      etc.
\                         FB       \ acknowledge packet

\ MOD: PLB 4/2/91 Set delay lower on AMIGAs.

ANEW TASK-FILE_XFER
decimal

128 constant MFX_BLOCK_SIZE

create MFX-BUFFER  mfx_block_size 4 + allot
variable MFX-COUNT   \ how many characters have been received
variable MFX-SIZE    \ number of data bytes in incoming packet
variable MFX-DONE
variable MFX-FILEID
variable MFX-SHOW
variable MFX-CHANNEL
mfx-show on
variable CONVERT-EOL
variable MFX-MODE
convert-eol on

\ Define codes per spec.
$ FB constant ACK_CODE    \ MIDI Continue
$ FC constant CANCEL_CODE    \ MIDI Stop

125 constant FILENAME_PACKET
126 constant DATA_PACKET
127 constant END_PACKET

\ Code ------------------------------------------------------

: MFX.OPEN.FILE  ( $filename -- error? )
    $fopen dup 0=
    IF  mfx-fileid off
        ." Couldn't open file!" cr true
    ELSE
        mfx-fileid ! false
    THEN
;

: MFX.CLOSE.FILE ( -- , close file if open )
    mfx-fileid @ ?dup
    IF fclose mfx-fileid off
    THEN
;

: MFX.SEND.SHAKE ( code -- , send handshake code)
	midi.xmit midi.flush
	mfx-show @
    IF ." |" flushemit cr?
	THEN
;

: MFX.ABORT ( -- )
    ." MFX aborting!" cr
    mfx.close.file
	cancel_code mfx.send.shake
    abort
;

: ?ABORT.MFX ( -- )
    ?terminal
    IF key ascii q =
       IF mfx.abort
       ELSE ." Hit 'q' to abort!" cr
       THEN
    THEN
;

\ Low Level MIDI I/O
variable MFX-DELAY-MS
10 mfx-delay-ms !

." MFX-DELAY-MS = " mfx-delay-ms @ . cr

: MFX.XMIT  ( byte -- , xmit with delay )
    mfx-delay-ms @ ?dup
    IF msec
    THEN
    midi.xmit midi.flush
;

: mfx.key  ( -- byte )
    BEGIN midi.recv 0=
    WHILE ?abort.mfx
    REPEAT
    if-debug @
    IF dup .hex cr?
    THEN
;

: MIDI.WAIT.BYTE ( byte -- , skip bytes until specific one received )
    BEGIN mfx.key
        over =
    UNTIL drop
;
\ ----------------------------------------------

: MFX.XMIT.START  ( packet_type -- , 126 or 127 )
	$ CF mfx.xmit
	mfx.xmit
;

: MFX.XMIT.DATUM  ( byte -- )
	dup $ 7F >
	IF ." Warning - byte in file greater then $7F clipped!" cr
		$ 7F and
	THEN
	mfx.xmit
;

: MFX.XMIT.STRING  ( addr count -- , send raw data )
	$ 9F mfx.xmit
    dup 14->7lo7hi swap mfx.xmit mfx.xmit
    BEGIN dup 0>
    WHILE 2dup 2 min >r
        dup c@ mfx.xmit.datum
		1+ c@ mfx.xmit.datum
        ( -- addr count)
        r@ - swap
		r> + swap
    REPEAT 2drop
;


: MFX.CONVERT->EOL  ( count -- , convert MFX buffer)
    dup mfx_block_size >
    IF ." MFX.CONVERT->EOL - count too big = " dup . cr?
        mfx.abort
    THEN
    0 DO
        mfx-buffer i + c@  ( get char )
        dup 10 = swap 13 = or
        IF eol mfx-buffer i + c!
        THEN
    LOOP
;

: MFX.WAIT.SHAKE ( -- , for handshake from receiver )
	BEGIN  mfx.key
		dup cancel_code =
		IF ." Cancel received!" mfx.abort
		THEN
		ack_code =
	UNTIL
	mfx-show @
    IF ." |" flushemit cr?
	THEN
;

: MFX.XMIT.DATA.PACKET  ( addr count -- )
    data_packet mfx.xmit.start
    mfx.xmit.string
	mfx-show @
    IF ." =" flushemit cr?
	THEN
;

: MFX.XMIT.BODY  ( -- )
    BEGIN
\ Read data from file.
        mfx-fileid @ mfx-buffer mfx_block_size fread
\ Debug help.
        if-debug @
        IF ." Line = " mfx-buffer over type
        THEN \ dup ." #chars = " . cr
\ Data left in file?
        dup 0>
    WHILE ( -- count )
        mfx-buffer swap mfx.xmit.data.packet
        mfx.wait.shake
    REPEAT
;

: $MFX.XMIT.STARTF ( $name -- , send filename )
    filename_packet mfx.xmit.start
    count mfx.xmit.string
;

: MFX.XMIT.ENDF ( -- )
	end_packet mfx.xmit.start
;

: (MFX.XMIT.FILE)  ( $name -- error?)
    midi.clear
    dup $mfx.xmit.startf  mfx.wait.shake
    ." Send " count type cr
    mfx.xmit.body
    mfx.xmit.endf
;

: $MFX.XMIT.FILE  ( $filename -- error? , send file over MIDI )
    dup mfx.open.file
    IF  drop true
    ELSE  (mfx.xmit.file)
        mfx.close.file
    THEN
;

: MFX.XMIT.FILE   ( <filename> -- error? )
    fileword $mfx.xmit.file
;

\ Code for Receiving a file ------------------------

: MFX.WRITE.BODY  ( -- )
    mfx-size @ 0>
    IF  convert-eol @
    	IF mfx-size @ mfx.convert->eol
    	THEN
\
		if-debug @
        IF ." Line = " mfx-buffer mfx-size @ type
        THEN
\
        mfx-fileid @ dup 0= abort" File start not received!"
        mfx-buffer mfx-size @ fwrite
        mfx-size @ -
        IF ." MFX.RECV.BODY - Write failed!" cr
           mfx.abort
        ELSE ack_code mfx.send.shake
        THEN
    ELSE cancel_code mfx.send.shake
    THEN
;
    
: MFX.GET.NAME  ( -- $filename )
	mfx-buffer mfx-size @
    dup pad c!
    pad 1+ swap cmove
    pad
;

: MFX.RECV.PRESET  ( preset -- , code for packet type )
	if-debug @
	IF dup ." Packet = " .hex cr?
	THEN
    dup mfx-mode !
	end_packet =
	IF	mfx.close.file >newline ." File Received!" cr
		mfx-done on 
	THEN
	0 mfx-size !
;

: MFX.ADD.BUFFER  ( char -- add to buffer )
    mfx-buffer mfx-count @ + c!
	1 mfx-count +!
;

: MFX.RECV.NOTE  ( note velocity -- )
	if-debug @
	IF ." NOTE* " 2dup swap .hex .hex cr?
	THEN
    mfx-size @ 0=
	IF \ we are waiting for a size
		7lo7hi->14 dup mfx-size !
        mfx_block_size > abort" Packet too large!"
		0 mfx-count !
	ELSE   ( byten byten+1 -- , add text to buffer )
		swap mfx.add.buffer mfx.add.buffer
	THEN
	mfx-count @ mfx-size @ >= \ At end of packet?
	IF mfx-mode @
		CASE
		filename_packet OF ." File = " mfx.get.name dup count type cr
    			new mfx.open.file   abort" MFX.RECV.NOTE"
				ack_code mfx.send.shake
			ENDOF
		data_packet OF mfx.write.body
			ENDOF
		ENDCASE
		mfx-count off
		mfx-size off
	THEN
;

: <MIDI.RECV.FILE> ( -- )
    mfx-done off
	mp.reset
	'c mfx.recv.preset mp-program-vector !
	'c mfx.recv.note   mp-on-vector !
	'c mfx.recv.note   mp-off-vector !  ( in case vel=0 )
	BEGIN midi.parse
	    mfx-done @ ?terminal or
	UNTIL
	mfx.close.file  ( just in case aborted )
;

: RECV.FILE ( -- )
    >newline ." Transmit File from other machine." cr
    midi.clear
    <midi.recv.file>
;

: RECV.FILES
    >newline ." Transmit files from other machine." cr
    BEGIN <midi.recv.file>
		?terminal
    UNTIL
;
    
: XMIT.FILE ( <name> -- , send file check for errors )
    mfx.xmit.file
    IF ." Error sending file!" cr? mfx.abort
    THEN
;

: MRFS ( -- , receive multiple files )
    recv.files
;
