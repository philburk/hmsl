\ $Id$
\ LOAD HMSL
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
ANEW TASK-LOAD_HMSL

false constant HOST=AMIGA
true constant HOST=MAC

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

include? task-stubs fth/stubs.fth

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
TRUE if-load-actions !    ( perform screen )
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

include? task-misc_tools        fth/misc_tools.fth
include? task-utils             fth/utils.fth
include? stack.header           fth/stacks.fth

include? task-errormsg          fth/errormsg.fth
include? task-memalloc          fth/memalloc.fth
include? task-cond_comp         fth/cond_comp.fth

include? task-global_data       fth/global_data.fth
include? task-service_tasks     fth/service_tasks.fth
include? task-float_port        fth/float_port.fth

\ MIDI and Time support-------------------------------
if-load-midi @ [IF]
  include? task-midi_globals fth/midi_globals.fth
  include? task-time fth/time.fth
  include? task-midi fth/midi.fth
  include? task-midi_parser fth/midi_parser.fth
  include? task-midi_text fth/midi_text.fth
[ELSE]
  include? task-midi_stubs fth/midi_stubs.fth
[THEN]

\
\ Object Oriented Code -------------------------
include? task-ob_stack fth/ob_stack.fth
include? task-ob_main fth/ob_main.fth
include? task-ob_bind fth/ob_bind.fth
include? task-obmethod fth/obmethod.fth
mreset-warn off
include? task-ob_ivars fth/ob_ivars.fth
include? task-dbl_list fth/dbl_list.fth
include? task-obobject fth/obobject.fth
include? task-ob_array fth/ob_array.fth
include? task-elmnts fth/elmnts.fth
include? task-ob_dlist fth/ob_dlist.fth

\ Support for interactive screens
if-load-graphics @ [IF]
  include? task-graphics fth/graphics.fth
  include? task-graph_util fth/graph_util.fth
  include? task-scg fth/scg.fth
  include? task-bevel fth/bevel.fth
  include? task-control fth/control.fth
  include? task-ctrl_count fth/ctrl_count.fth
  include? task-ctrl_numeric fth/ctrl_numeric.fth
  include? task-ctrl_fader fth/ctrl_fader.fth
  include? task-screen fth/screen.fth
  include? task-ctrl_text fth/ctrl_text.fth
  include? task-popup_text fth/popup_text.fth
[THEN]

\ HMSL Music Morphs
if-load-morphs @ [IF]
include? task-morph_lists fth/morph_lists.fth
include? task-morph fth/morph.fth
include? task-actobj fth/actobj.fth
include? task-collection fth/collection.fth
include? task-shape fth/shape.fth
include? task-structure fth/structure.fth
include? task-production fth/production.fth
include? task-event_list fth/event_list.fth
include? task-allocator fth/allocator.fth
include? task-translators fth/translators.fth
include? task-instrument fth/instrument.fth
if-load-midi @ [IF]
include? task-midi_instrument fth/midi_instrument.fth
[THEN]
include? task-job fth/job.fth
include? task-player fth/player.fth
include? task-interpreters fth/interpreters.fth
[THEN]

\ Some predefined morphs.
if-load-morphs @ [IF]
include? task-stock_morphs fth/stock_morphs.fth
[THEN]

if-load-graphics @ [IF]
include? task-build_menus fth/build_menus.fth
[THEN]

if-load-demo @ 0= if-load-morphs @ and [IF]
include? task-record fth/record.fth
include? task-packed_midi fth/packed_midi.fth
[THEN]

include? task-top fth/top.fth

\ include? task-set_vectors fth/set_vectors.fth
include? task-hmsl_version fth/hmsl_version.fth
include? task-hmsl_top fth/hmsl_top.fth
include? task-startup fth/startup.fth


\ Editors in screen are loaded on top of the regular HMSL
if-load-graphics @   if-load-shape-ed @ AND [IF]
    include? task-shape_editor fth/shape_editor.fth
[THEN]

\ Load actions by Larry Polansky ,  "PERFORM" module
if-load-graphics @ if-load-actions @ AND [IF]
    include? task-action_utils fth/action_utils.fth
    include? task-ob_actions fth/ob_actions.fth
    include? task-test_actions fth/test_actions.fth
    include? task-action_table fth/action_table.fth
    include? task-action_screen fth/action_screen.fth
    include? task-action_top fth/action_top.fth
[THEN]

\ load some tools
include? file_port tools/file_port.fth
include? task-midifile tools/midifile.fth
include? task-markov_chain tools/markov_chain.fth
include? task-score_entry tools/score_entry.fth

mreset-warn on
cr ." HMSL compilation finished." cr
map

ANEW SESSION

