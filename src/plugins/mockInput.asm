;====
; Mocks the input ports ($DC and $DD) for controller 1 and controller 2
;====

.define zest.mockInput 1

;====
; Constants
;====
.define zest.UP           %00000001
.define zest.DOWN         %00000010
.define zest.LEFT         %00000100
.define zest.RIGHT        %00001000
.define zest.BUTTON_1     %00010000
.define zest.BUTTON_2     %00100000
.define zest.NO_INPUT     %00000000

;====
; RAM variables
;====
.ramsection "zest.mockInput" slot zest.mapper.RAM_SLOT
    ; Fake value for port DC
    zest.mockInput.portDC:    db

    ; Fake value for port DD
    zest.mockInput.portDD:    db
.ends

;====
; Reset the port values at the beginning of each test
;====
.section "zest.mockInput.init" appendto zest.preTest
    zest.mockInput.init:
        ld a, $ff   ; no buttons pressed
        ld (zest.mockInput.portDC), a
        ld (zest.mockInput.portDD), a
.ends

;====
; Sets the fake input values for controller 1. These buttons will included in
; fake port $dc value (%--21rldu)
;
; @in   value   the pressed buttons (zest.UP, zest.DOWN etc)
;               combine multiple buttons with | (i.e. zest.UP|zest.BUTTON_1)
;====
.macro "zest.mockController1" args value
    zest.utils.assert.equals NARGS, 1, "\. expects 1 argument (i.e. zest.UP, zest.DOWN). Combine multiple with '|', i.e zest.UP | zest.BUTTON_1"
    zest.utils.assert.byte value, "\. expects a numeric byte value"

    \@_\.:
    push af
        ld a, (zest.mockInput.portDC)
        and %11000000                   ; clear current controller 1 buttons
        or (value ~ $ff)                ; sets values (invert so 0 = pressed)
        ld (zest.mockInput.portDC), a   ; store
    pop af
.endm

;====
; Sets the fake input values for controller 2. These values will be included
; in the fake port $dc and $dd values ($dc = %du------, $dd = %----21rl)
;
; @in   value   the pressed buttons (zest.UP, zest.DOWN etc)
;               combine multiple buttons with | (i.e. zest.UP|zest.BUTTON_1)
;====
.macro "zest.mockController2" args value
    zest.utils.assert.equals NARGS, 1, "\. expects 1 argument (i.e. zest.UP, zest.DOWN). Combine multiple with '|', i.e zest.UP | zest.BUTTON_1"
    zest.utils.assert.byte value, "\. expects a numeric byte value"

    \@_\.:
    push af
        ld a, value ~ $ff   ; invert so 0 = pressed
        call zest.mockInput._controller2
    pop af
.endm

;====
; Loads A with the fake $dc port value
;
; @out  a   the fake $dc port value
;====
.macro "zest.loadFakePortDC"
    ld a, (zest.mockInput.portDC)
.endm

;====
; Loads A with the fake $dd port value#
;
; @out  a   the fake $dd port value
;====
.macro "zest.loadFakePortDD"
    ld a, (zest.mockInput.portDD)
.endm

;====
; (Private) Mocks the raw controller 2 input
;
; @in   a   input values (--21rldu) (0 = pressed)
;====
.section "zest.mockInput._setController2" free
    zest.mockInput._controller2:
        push bc
            ld b, a                          ; preserve input in B

            ;===
            ; Load current fake portDC value. This mostly contains controller 1
            ; buttons but also contains UP and DOWN for controller 2 (DU------)
            ;===
            ld a, (zest.mockInput.portDC)   ; load current stubbed value
            and %00111111                   ; reset current up and down port 2
            ld c, a                         ; preserve in C

            ; Set the fake UP and DOWN values in fake port $DC
            ld a, b                         ; restore fake input (--21rldu)
            rrca                            ; u--21rld
            rrca                            ; du--21rl
            ld b, a                         ; preserve rotated value in B
            and %11000000                   ; du------
            or c                            ; combine with current fake portDC
            ld (zest.mockInput.portDC), a   ; store result

            ; Store remaining values in fake port $DD
            ld a, b                         ; du--21rl
            or %11110000                    ; ----21rl
            ld (zest.mockInput.portDD), a   ; load current stubbed value
        pop bc

        ret
.ends
