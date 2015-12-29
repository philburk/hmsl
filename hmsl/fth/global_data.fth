\ Global Data used by many modules in HMSL

ANEW TASK-GLOBAL_DATA

variable HMSL-WINDOW   ( window to use for drawing HMSL )

variable TICKS/BEAT
rtc.rate@ 2 * 3 / ticks/beat !

variable TIMESIG-NUMER  ( numerator )
4 timesig-numer !

variable TIMESIG-DENOM  ( denomonator )
4 timesig-denom !

variable QUIT-HMSL    ( quit if set true by anyone )

