\ Patch JForth Bugs or Other Undesirable effects

ANEW TASK-PATCHES

\ FORGET currently calls DEFINITIONS which seems unnecessary.
: [FORGET]  ( <name> -- )
    current @
    [forget]
    dup 0 here within?  ( vocabulary not forgotten? )
    IF current !
    ELSE drop
    THEN
;

