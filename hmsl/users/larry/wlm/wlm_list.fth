\ WLM
\ object lists
\ 5/12/92
\ 5/22/92
\ author: lp


\ this file is simply a kind of updated list for indexing through WLM's
\ the lists are used by the wlm screen
\ one method, a kind of random wlm starter and stopper, is defined
\ this file could easily be extended with user functions for specific pieces

ANEW TASK-WLM_LISTS


\ randomly starts and stops jobs from the list
\ the list is  16 long in the screen, but doesn't have to be....
: WLM-LIST-JOB.FUNCTION { job -- }
    many: wlm-list
    choose  at: wlm-list
    2 choose IF start: [] ELSE stop: [] THEN
    300 60 wchoose job put.duration: []
;

\ this is the job that randomly starts and stops wlm's from the lsit
: INIT.WLM-LIST-JOB
    1 new: wlm-list-job
    300 60 wchoose put.duration: wlm-list-job
    'c wlm-list-job.function add: wlm-list-job
;

\ this little function starts all wlm's that are currently on at the
\ same time. very useful for creating polyrhthm type of effects, and so on
: SYNC.WLMS
    many: wlm-list 0
    DO
        i at: wlm-list get.on?: []
        IF
            i at: wlm-list start: []
        THEN
    LOOP
;


\ this sets up the list to be 16 long, and puts 16 wlm's into it...
: INIT.WLM-LIST { | wlm -- }
    #-channels new: wlm-list
    #-channels 0 DO
        instantiate ob.wlm
        -> wlm
        wlm setup: []
        i 1+ wlm put.data: []
        i 1+ wlm put.channel: []
        default_preset wlm put.preset-#: []
        wlm add: wlm-list
    LOOP
    init.wlm-list-job
;


\ INIT.WLM-LIST is called when the screen is set up....

: TERM.WLM-LIST
    freeall: wlm-list
    free: wlm-list
    free: wlm-list-job
;

IF.FORGOTTEN TERM.WLM-LIST
