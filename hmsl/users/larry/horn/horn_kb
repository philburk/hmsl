\ HORN 
\ composer LP
\ 2/26/90
\ keyboard interpretive part...
anew task-Horn_kb
v: temp-channel
: HORN.KB.ON { note vel -- fb fb.fract vel }
	many: arp-shape 0 DO
		i 1 ed.at: arp-shape
		note = 
		IF 
			midi-channel @ temp-channel !
			fb.start.events
			note 
			i 2 ed.at: arp-shape
			vel
			16 midi-channel ! 
			fb.fract.on
			temp-channel @ midi.channel!
			LEAVE
		THEN
	LOOP
;

'c horn.kb.on mp-on-vector !		
: HORN.KB.OFF { note vel -- fb fb.fract  }
	many: arp-shape 0 DO
		i 1 ed.at: arp-shape
		note  = 
		IF
			midi-channel @ temp-channel !
			fb.start.events
			note 
			i 2 ed.at: arp-shape
			16 midi.channel!
			fb.fract.off
			temp-channel @ midi.channel!
			LEAVE
		THEN
	LOOP
;

'c horn.kb.off mp-off-vector !		
	
