\ $Id$
\ LOAD HMSL
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ anew task-load_hmsl.fth

: '  ( <name> -- cfa , warn me if used the wrong way )
	state @
	IF
		." ' used! ====================" cr
		source type cr
		." ============================" cr
		postpone '
	ELSE
		'
	THEN
; immediate

include? task-stubs.fth         fth/stubs.fth

: [NEED] ( <name> -- start compiling if not found )
    postpone exists? not postpone [IF]
;

\ Decide whether to compile different parts of HMSL.
[need] IF-LOAD-MIDI
variable IF-LOAD-MIDI
variable IF-LOAD-ACTIONS
variable IF-LOAD-MORPHS
variable IF-LOAD-GRAPHICS
variable IF-LOAD-SHAPE-ED
variable IF-LOAD-DEMO
if-load-demo off
[THEN]

\ SET THESE VARIABLES TO CONTROL WHAT GETS LOADED!!!!
TRUE if-load-midi !
TRUE if-load-morphs !
FALSE if-load-actions !    ( perform screen )
TRUE if-load-graphics !
if-load-morphs @ if-load-shape-ed !

if-load-midi @ 0= [IF] ." Not loading MIDI support!" cr [THEN]
if-load-actions @ 0= [IF] ." Not loading Actions or Perform Screen!" cr [THEN]
if-load-graphics @ 0= [IF] ." Not loading Graphics Support" cr [THEN]
if-load-shape-ed @ 0= [IF] ." Not loading Shape Editor" cr [THEN]

\ Start of cascaded initialization and termination.
exists? SYS.INIT not [if] 
    : SYS.INIT ;
    : SYS.TERM ;
    : SYS.RESET ;
[THEN]

exists?  SYS.CLEANUP not [if]
    : SYS.CLEANUP ; \ less severe then SYS.RESET
    : SYS.START ;
    : SYS.STOP ;
    : SYS.TASK ;
[THEN]

exists? SYS.STATUS not [if]
    : SYS.STATUS >newline ;
[THEN]

include? within?                fth/p4thbase.fth
include? toupper                fth/charmacr.fth

include? task-misc_tools.fth    fth/misc_tools.fth
include? task-utils.fth         fth/utils.fth
include? stack.header 		    fth/stacks.fth

include? task-errormsg.fth		fth/errormsg.fth
include? task-memalloc.fth      fth/memalloc.fth


include? task-global_data.fth	fth/global_data.fth
include? task-service_tasks fth/service_tasks.fth

\ MIDI and Time support-------------------------------
if-load-midi @ [IF]
  include? task-midi_globals.fth fth/midi_globals.fth
  include? task-time	        fth/time.fth
  include? task-midi		    fth/midi.fth
  include? task-midi_parser.fth	fth/midi_parser.fth
  include? task-midi_text	    fth/midi_text.fth
[ELSE]
  include? task-midi_stubs      fth/midi_stubs.fth
[THEN]

\
\ Object Oriented Code -------------------------
include? task-ob_stack.fth    fth/ob_stack.fth
include? task-ob_main.fth     fth/ob_main.fth
include? task-ob_bind.fth     fth/ob_bind.fth
include? task-obmethod.fth    fth/obmethod.fth
mreset-warn off
include? task-ob_ivars.fth    fth/ob_ivars.fth
include? task-dbl_list.fth    fth/dbl_list.fth
include? task-obobject.fth    fth/obobject.fth
include? task-ob_array.fth    fth/ob_array.fth
include? task-elmnts.fth      fth/elmnts.fth
include? task-ob_dlist.fth    fth/ob_dlist.fth

\ Support for interactive screens
if-load-graphics @ [IF]
  include? task-graphics.fth  fth/graphics.fth
  include? task-graph_util	  fth/graph_util.fth
  include? task-scg.fth		  fth/scg.fth
  include? task-bevel		  fth/bevel.fth
  include? task-control		  fth/control.fth
  include? task-ctrl_count	  fth/ctrl_count.fth
  include? task-ctrl_numeric  fth/ctrl_numeric.fth
  include? task-ctrl_fader    fth/ctrl_fader.fth
  include? task-screen.fth		  fth/screen.fth
  include? task-ctrl_text.fth     fth/ctrl_text.fth
  include? task-popup_text.fth    fth/popup_text.fth
[THEN]


\ HMSL Music Morphs
if-load-morphs @ [IF]
include? task-morph_lists.fth fth/morph_lists.fth
include? task-morph.fth       fth/morph.fth
include? task-actobj.fth      fth/actobj.fth
include? task-collection.fth  fth/collection.fth
include? task-shape.fth       fth/shape.fth
include? task-structure.fth   fth/structure.fth
include? task-production.fth  fth/production.fth
include? task-event_list.fth  fth/event_list.fth
include? task-allocator.fth   fth/allocator.fth
include? task-translators.fth fth/translators.fth
include? task-instrument.fth  fth/instrument.fth
if-load-midi @ [IF]
include? task-midi_instrument.fth fth/midi_instrument.fth
[THEN]
include? task-job.fth         fth/job.fth
include? task-player.fth      fth/player.fth
include? task-interpreters.fth fth/interpreters.fth
[THEN]

\ Some predefined morphs.
if-load-morphs @ [IF] 
include? task-stock_morphs.fth    fth/stock_morphs.fth
[THEN]

if-load-graphics @ [IF]
include? task-build_menus.fth fth/build_menus.fth
[THEN]

if-load-demo @ 0= if-load-morphs @ and [IF]
include? task-record          fth/record.fth
include? task-packed_midi     fth/packed_midi.fth
[THEN]

include? task-top.fth         fth/top.fth

\ include? task-set_vectors.fth fth/set_vectors.fth
include? task-hmsl_version.fth fth/hmsl_version.fth
include? task-hmsl_top.fth    fth/hmsl_top.fth
include? task-startup.fth     fth/startup.fth


\ Editors in screen are loaded on top of the regular HMSL
if-load-graphics @   if-load-shape-ed @ AND [IF]
	include? task-shape_editor.fth fth/shape_editor.fth
[THEN]

0 [IF]
	\ Load actions by Larry Polansky ,  "PERFORM" module
	if-load-graphics @ if-load-actions @ AND [IF]
		include? task-action_utils	fth/action_utils
		include? task-ob_actions	fth/ob_actions
		include? task-test_actions	fth/test_actions
		include? task-action_table	fth/action_table
		include? task-action_screen	fth/action_screen
		include? task-action_top	fth/action_top
	[THEN]
[THEN]

\ load some tools
include? task-midifile	           tools/midifile.fth
include? task-score_entry	       tools/score_entry.fth

mreset-warn on
cr ." HMSL compilation finished." cr
map

ANEW SESSION

