;====
; Our real code would have a macro like this. We won't import this into our
; suite though, and instead create a fake one that loads A with the value
; we want
;====
.macro "readPort" args portNumber
    in a, (portNumber)
.endm