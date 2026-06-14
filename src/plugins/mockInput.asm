;====
; Mocks the input ports ($DC and $DD) for controller 1 and controller 2
;====

.define zest.plugin.mockInput 1

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
; Reset the port values at the beginning of each test
;====
.section "zest.mockInput.init" appendto zest.preTest
    zest.mockInput.init:
        ld a, $ff   ; no buttons pressed
        zest.ports.set $dc
        zest.ports.set $dd
.ends

;====
; Sets the fake input values for controller 1. These buttons will included in
; fake port $dc value (%--21rldu)
;
; @in   value   the pressed buttons (zest.UP, zest.DOWN etc)
;               combine multiple buttons with | (i.e. zest.UP|zest.BUTTON_1)
;====
.macro "zest.mockController1" args value
    zest.utils.validate.equals NARGS, 1, "\. expects 1 argument (i.e. zest.UP, zest.DOWN). Combine multiple with '|', i.e zest.UP | zest.BUTTON_1"
    zest.utils.validate.byte value, "\. expects a numeric byte value"

    \@_\.:
    push bc
        ld b, value ~ $ff               ; invert so 0 = pressed
        call zest.mockInput._controller1
    pop bc
.endm

;====
; Sets the fake input values for controller 2. These values will be included
; in the fake port $dc and $dd values ($dc = %du------, $dd = %----21rl)
;
; @in   value   the pressed buttons (zest.UP, zest.DOWN etc)
;               combine multiple buttons with | (i.e. zest.UP|zest.BUTTON_1)
;====
.macro "zest.mockController2" args value
    zest.utils.validate.equals NARGS, 1, "\. expects 1 argument (i.e. zest.UP, zest.DOWN). Combine multiple with '|', i.e zest.UP | zest.BUTTON_1"
    zest.utils.validate.byte value, "\. expects a numeric byte value"

    \@_\.:
    push bc
        ld b, value ~ $ff   ; invert so 0 = pressed
        call zest.mockInput._controller2
    pop bc
.endm

;====
; (Private) Mocks the raw controller 1 input
;
; @in   b   input values (--21rldu) (0 = pressed)
;====
.section "zest.mockInput._setController1" free
    zest.mockInput._controller1:
        push af
            zest.ports.loadA $dc    ; load current stubbed value
            and %11000000           ; clear current controller 1 buttons
            or b                    ; set values
            zest.ports.set $dc      ; store result
        pop af

        ret
.ends

;====
; (Private) Mocks the raw controller 2 input
;
; @in   b   input values (--21rldu) (0 = pressed)
;====
.section "zest.mockInput._setController2" free
    zest.mockInput._controller2:
        push af
            ;===
            ; Load current fake portDC value. This mostly contains controller 1
            ; buttons but also contains UP and DOWN for controller 2 (DU------)
            ;===
            zest.ports.loadA $dc    ; load current stubbed value
            and %00111111           ; reset current up and down port 2
            ld c, a                 ; preserve in C

            ; Set the fake UP and DOWN values in fake port $DC
            ld a, b                 ; restore fake input (--21rldu)
            rrca                    ; u--21rld
            rrca                    ; du--21rl
            ld b, a                 ; preserve rotated value in B
            and %11000000           ; du------
            or c                    ; combine with current fake portDC
            zest.ports.set $dc      ; store result

            ; Store remaining values in fake port $DD
            ld a, b                 ; du--21rl
            or %11110000            ; ----21rl
            zest.ports.set $dd      ; store result
        pop af

        ret
.ends
