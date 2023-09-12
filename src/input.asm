;====
; Dependencies
;====
.ifndef utils.assert
    .include "./utils/assert.asm"
.endif

;====
; RAM variables
;====
.ramsection "zest.mockInput" slot zest.RAM_SLOT
    zest.mockInput.portDC:    db
    zest.mockInput.portDD:    db
.ends

;====
; Resets the stubbed port values to their defaults
;====
.macro "zest.mockInput.init"
    ld a, $ff   ; no buttons pressed
    ld (zest.mockInput.portDC), a
    ld (zest.mockInput.portDD), a
.endm

;====
; Mocks the raw controller 1 input
;
; @in   value   input.UP, input.DOWN etc. Boolean OR multiple buttons together
;               i.e. input.UP | input.LEFT (means both UP and LEFT are pressed)
;====
.macro "zest.mockInput.controller1" args value
    utils.assert.equals NARGS, 1, "mock/utils/port.asm \.: Expected a single argument"
    utils.assert.range value, 0, 255, "mock/utils/port.asm \.: Expected a value in the range of 0-255"

    \@_\.:
    push af
        ld a, (zest.mockInput.portDC)
        and %11000000                   ; clear current controller 1 buttons
        or (value ~ $ff)                ; set inverse of values (0 = pressed)
        ld (zest.mockInput.portDC), a   ; store
    pop af
.endm

;====
; Mocks the raw controller 2 input
; @in   a   input values (--21rldu) (0 = pressed)
;====
.section "zest.mockInput._controller2" free
    zest.mockInput._controller2:
        push bc
            ld b, a                             ; preserve input in B

            ;===
            ; Load current fake portDC value. This contains UP and DOWN for
            ; controller 2)
            ;===
            ld a, (zest.mockInput.portDC)   ; load current stubbed value
            and %00111111                   ; reset current up and down port 2
            ld c, a                         ; preserve in C

            ; Set the fake UP and DOWN values
            ld a, b                         ; restore fake input (--21rldu)
            rrca                            ; u--21rld
            rrca                            ; du--21rl
            ld b, a                         ; preserve rotated value in B
            and %11000000                   ; du------
            or c                            ; combine with current fake portDC
            ld (zest.mockInput.portDC), a   ; store result

            ; Store remaining values in port DD
            ld a, b                         ; du--21rl
            or %11110000                    ; ----21rl
            ld (zest.mockInput.portDD), a   ; load current stubbed value
        pop bc
        ret

.ends

;====
; Mocks the raw controller 2 input
;
; @in   value   input.UP, input.DOWN etc. Boolean OR multiple buttons together
;               i.e. input.UP | input.LEFT (means both UP and LEFT are pressed)
;====
.macro "zest.mockInput.controller2" args value
    utils.assert.equals NARGS, 1, "mock/utils/port.asm \.: Expected a single argument"
    utils.assert.range value, 0, 255, "mock/utils/port.asm \.: Expected a value in the range of 0-255"

    \@_\.:
    push af
        ld a, value ~ $ff
        call zest.mockInput._controller2
    pop af
.endm
