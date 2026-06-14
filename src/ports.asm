;====
; Stores mock values for the various input ports. These can't mock the values
; returned from the `in a, (port)` instruction, so a proxy macro in a separate
; file will need to be used to run that instruction. The code will use this
; macro, and in the test suite it should be replaced with a mock equivalent
; that calls the `zest.ports.loadA` macro instead.
;====

; VDP status flags
.ramsection "zest.ports.ram.bf" slot zest.mapper.RAM_SLOT
    zest.ports.ram.mockBF: db
.ends

; Controller 1 and some of controller 2
.ramsection "zest.ports.ram.dc" slot zest.mapper.RAM_SLOT
    zest.ports.ram.mockDC: db
.ends

; Rest of controller 2 + misc.
.ramsection "zest.ports.ram.dd" slot zest.mapper.RAM_SLOT
    zest.ports.ram.mockDD: db
.ends

;====
; Store a mock value for the given port
;
; @in   a           the value to store in the port
; @in   portNumber  the port number to mock (i.e. $dc, $dd, $bf)
;====
.macro "zest.ports.set" args portNumber
    zest.utils.validate.byte portNumber, "\. expects a numeric byte value for portNumber"

    \@_\.:
        .if portNumber == $bf
            ld (zest.ports.ram.mockBF), a
        .elif portNumber == $dc
            ld (zest.ports.ram.mockDC), a
        .elif portNumber == $dd
            ld (zest.ports.ram.mockDD), a
        .else
            .print "\. currently does not support mocking port $", hex portNumber, "\n"
            .fail
        .endif
.endm

;====
; Load the previously mocked value from the given port into register A
;
; @in   portNumber  the port number to load (i.e. $dc, $dd, $bf)
;====
.macro "zest.ports.loadA" args portNumber
    zest.utils.validate.byte portNumber, "\. expects a numeric byte value for portNumber"

    \@_\.:
        .if portNumber == $bf
            ld a, (zest.ports.ram.mockBF)
        .elif portNumber == $dc
            ld a, (zest.ports.ram.mockDC)
        .elif portNumber == $dd
            ld a, (zest.ports.ram.mockDD)
        .else
            .print "\. currently does not support port $", hex portNumber, "\n"
            .fail
        .endif
.endm