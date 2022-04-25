\ LOAD HMSL - Hierarchical Music Specification Language.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ You must have done:
\
\      EXECUTE JForth:ASSIGNS
\
\ before loading this file.
\
\ MOD: PLB 9/7/87 Use MODULE instead of SPLIT.INCLUDE
\ MOD: PLB 2/27/90 This file for both Mac and Amiga
\
\ Host dependant Constant
\ set these constants based on machine specific words
.need HOST=MAC
exists? FILE-CREATOR constant HOST=MAC
exists? DOS_LIB constant HOST=AMIGA
.then

\ Decide whether to compile different parts of HMSL.
.need IF-LOAD-MIDI
variable IF-LOAD-AMIGA-DA
variable IF-LOAD-MIDI
variable IF-LOAD-ACTIONS
variable IF-LOAD-MORPHS
variable IF-LOAD-GRAPHICS
variable IF-LOAD-SHAPE-ED
variable IF-LOAD-DEMO
if-load-demo off
.THEN

\ SET THESE VARIABLES TO CONTROL WHAT GETS LOADED!!!!
if-load-demo @ 0= host=amiga and if-load-amiga-da !   ( local sound )
TRUE if-load-midi !
TRUE if-load-morphs !
FALSE if-load-actions !    ( perform screen )
TRUE if-load-graphics !
if-load-morphs @ if-load-shape-ed !

if-load-amiga-da @ 0= 
   host=amiga AND .IF ." Not loading Amiga Local Sound!" cr .THEN
if-load-midi @ 0= .IF ." Not loading MIDI support!" cr .THEN
if-load-actions @ 0= .IF ." Not loading Actions or Perform Screen!" cr .THEN
if-load-graphics @ 0= .IF ." Not loading Graphics Support" cr .THEN
if-load-shape-ed @ 0= .IF ." Not loading Shape Editor" cr .THEN

\
\ Load some handy JForth tools.
host=amiga .IF
." Set MAX-INLINE to 6 to save RAM" cr
6 MAX-INLINE !
ONLY FORTH DEFINITIONS
VERIFY-LIBS OFF

\ include? opton		jf:opt.f
include? random		ju:random
include? logto		ju:logto
include? msec		ju:msec
include? {		ju:locals
.THEN

host=amiga .IF
include? task-ajf_dict ju:ajf_dict
\ Support for structures, includes and members.
include hh:ajf_includes 
.THEN

\ Start of cascaded initialization and termination.
.NEED SYS.INIT
    : SYS.INIT ;
    : SYS.TERM ;
    : SYS.RESET ;
    : SYS.CLEANUP ; \ less severe then SYS.RESET
    : SYS.START ;
    : SYS.STOP ;
    : SYS.TASK ;
.THEN
.NEED SYS.STATUS
    : SYS.STATUS >newline ;
.THEN

\ Miscellaneous utilities.
include? task-global_data	h:global_data
host=amiga .IF
include? task-ajf_base		hh:ajf_base
.THEN
host=mac .IF
include? task-h4th_config hh:h4th_config
include? task-char_macros hsys:char_macros
.THEN

include? task-misc_tools	h:misc_tools
include? task-utils			ho:utils
include? stack.header 		h:stacks

include? task-midi_globals	h:midi_globals

host=mac if-load-midi @ AND .IF
  INCLUDE? task-MIDIMgr.f	hh:MIDIMgr.f
  include? task-h4th_midi+rtc	hh:h4th_midi+rtc
  include? task-h4th_irq_timer	hh:h4th_irq_timer
  include? task-time			h:time
  include? task-h4th_midi_io	hh:h4th_midi_io
.THEN

if-load-amiga-da @ .IF
  include? task-amiga_sound	hh:amiga_sound
.THEN

host=amiga .IF
	include? task-ajf_rtc		hh:ajf_rtc
	include? task-time			h:time
	include? task-ajf_mm		hh:ajf_mm
.THEN
\ MIDI support.
if-load-midi @ host=amiga AND .IF
\ Event Buffering
	include? task-spawn_task	hh:spawn_task
	include? task-event_buffer	h:event_buffer
	include? task-timer_driven	hh:timer_driven
	include? task-eb_posting	h:eb_posting
	include? task-ajf_midi	hh:ajf_midi
.THEN

if-load-midi @ .IF
  include? task-midi		h:midi
  include? task-midi_parser	h:midi_parser
  include? task-midi_text	h:midi_text
.ELSE
  include? task-midi_stubs	h:midi_stubs
.THEN

\
\ Stubs to prevent unravel from loading.
\ .NEED UNRAVEL : UNRAVEL ; .THEN
include? task-er.report		ho:er.report
include? task-service_tasks	h:service_tasks

\ Mac specific graphics
if-load-graphics @ host=mac and .IF
  include? task-draghooks	hh:draghooks
  include? task-h4th_events hh:h4th_events
  include? task-h4th_graph hh:h4th_graph
.THEN

\ Amiga Intuition tools.
if-load-graphics @ host=amiga and .IF
include? gr.init ju:amiga_graph
include? task-amiga_events	ju:amiga_events
include? task-amiga_menus	ju:amiga_menus
include? task-ajf_events	hh:ajf_events
include? task-ajf_graph		hh:ajf_graph
.THEN

\
\ Object Oriented Code -------------------------
host=amiga .IF
include? task-obj_stack		ho:obj_stack
.THEN

host=mac .IF
include? task-obj_stack		hh:obj_stack
.THEN

include? task-obj_main		ho:obj_main
include? task-obj_binding	ho:obj_binding
include? task-obj_methods	ho:obj_methods
mreset-warn off
include? task-obj_ivars		ho:obj_ivars
include? task-Double_List	ho:Double_List
include? task-obj_object	ho:obj_object
include? task-obj_array		ho:obj_array
include? task-elmnts		ho:elmnts
include? task-circular		ho:circular

\ Support for interactive screens
if-load-graphics @ .IF
  include? task-graph_util	h:graph_util
  include? task-scg			h:scg
  include? task-bevel		h:bevel
  include? task-control		h:control
  include? task-ctrl_count	h:ctrl_count
  include? task-ctrl_numeric	h:ctrl_numeric
  include? task-screen		h:screen
.THEN

\ HMSL Music Morphs
if-load-morphs @ .IF
include? task-morph_lists	h:morph_lists
include? task-morph			h:morph
include? task-shape			h:shape
include? task-collection	h:collection
include? task-production	h:production
include? task-event_list	h:event_list
include? task-actobj		h:actobj
include? task-allocator		h:allocator
include? task-translators	h:translators
include? task-instrument	h:instrument
if-load-midi @ .IF
include? task-midi_instrument	h:midi_instrument
.THEN
include? task-job		h:job
include? task-player		h:player
include? task-interpreters	h:interpreters
.THEN

\ Amiga sound and instrument support.
if-load-amiga-da @ .IF
  include? task-amiga_sound	hh:amiga_sound
  include? task-8svx.j		hh:8svx.j
.THEN

if-load-morphs @ if-load-amiga-da @ AND .IF
  include? task-waveforms	hh:waveforms
  include? task-tunings		h:tunings
  include? task-ratios		h:ratios
  include? task-envelopes	hh:envelopes
  include? task-amiga_instrument  hh:amiga_instrument
.THEN
\
\ Some predefined morphs.
if-load-morphs @ .IF
include? task-stock_morphs	h:stock_morphs
.THEN

if-load-graphics @ host=mac AND .IF
include? task-h4th_build_menus hh:h4th_build_menus
.THEN

if-load-graphics @ host=amiga AND .IF
  include? task-ajf_menu	hh:ajf_menu
.THEN

host=amiga .IF
include? task-ajf_top		hh:ajf_top
include? task-multi_wait	hh:multi_wait
.THEN

if-load-demo @ 0= if-load-morphs @ and .IF
include? task-record		h:record
include? task-packed_midi	h:packed_midi
.THEN

host=mac .IF
include? task-h4th_top 		hh:h4th_top
.THEN

include? task-set_vectors 	h:set_vectors
include? task-hmsl_version	h:hmsl_version
include? task-hmsl_top		h:hmsl_top
include? task-startup		h:startup

\ Editors in screen are loaded on top of the regular HMSL
if-load-graphics @   if-load-shape-ed @ AND .IF
        include? task-shape_editor	h:shape_editor
.THEN

\ Load actions by Larry Polansky ,  "PERFORM" module
if-load-graphics @ if-load-actions @ AND .IF
  include? task-action_utils	h:action_utils
  include? task-ob_actions	h:ob_actions
  include? task-test_actions	h:test_actions
  include? task-action_table	h:action_table
  include? task-action_screen	h:action_screen
  include? task-action_top	h:action_top
.THEN

mreset-warn on
cr ." HMSL compilation finished." cr

host=amiga .IF
370 #K !
VERIFY-LIBS ON
.THEN

if-load-demo @ .IF 410 #K ! .THEN

host=mac .IF
240000 code-size !
100000 headers-size !
.THEN

ANEW SESSION

