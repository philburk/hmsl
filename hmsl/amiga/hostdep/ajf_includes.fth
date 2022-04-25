
.NEED HMSL-includes
    getmodule includes
    module HMSL-includes
    10 makemodule HMSL-includes
\
    include? message ji:exec/io.j
    include? exec_interrupts_h ji:exec/interrupts.j
    include? exec_libraries_h ji:exec/libraries.j
    include? exec_execbase_h ji:exec/execbase.j
\    include? IOEXtSer ji:devices/serial.j
    include? intuition_intuition_h h:int_tiny.j
    include? INTB_VERTB ji:hardware/intbits.j
    include? CIAICRB_TA ji:hardware/cia.j
    include? rp_fgpen ji:graphics/rastport.j
    include? MR_ALLOCMISCRESOURCE ji:resources/misc.j
\
    sealmodule hmod:HMSL-includes
.ELSE
    getmodule includes
    getmodule hmod:HMSL-includes
.THEN
