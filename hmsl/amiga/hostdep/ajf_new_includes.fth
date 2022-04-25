
.NEED HMSL-includes
    getmodule includes
    module HMSL-includes
    10 makemodule HMSL-includes
    include? task-ajf_includes h:ajf_includes
    sealmodule hmod:HMSL-includes
.ELSE
    getmodule includes
    getmodule hmod:HMSL-includes
.THEN
