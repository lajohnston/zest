;====
; Our real code would have a macro in a separate file like this. We won't
; import this into our suite though. We'll instead create a fake one in
; the suite that loads A with the value we want
;====
.macro "readPort" args portNumber
    in a, (portNumber)
.endm