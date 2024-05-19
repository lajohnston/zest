;====
; Compares all registers to the initial values set by zest.initRegisters, and
; fails the test if any values have changed
;====
.macro "expect.all.toBeUnclobbered"
    call expect.all._toBeUnclobbered
.endm

;====
; (Private) See expect.all.toBeUnclobbered macro
;====
.section "expect.all._toBeUnclobbered" free
    ; AF
    _failA:
        ld hl, expect.all.toBeUnclobbered.messageA
        jp zest.assertion.failed
    _failF:
        ld hl, expect.all.toBeUnclobbered.messageF
        jp zest.assertion.failed

    ; BC
    _failB:
        ld hl, expect.all.toBeUnclobbered.messageB
        jp zest.assertion.failed
    _failC:
        ld hl, expect.all.toBeUnclobbered.messageC
        jp zest.assertion.failed

    ; DE
    _failD:
        ld hl, expect.all.toBeUnclobbered.messageD
        jp zest.assertion.failed
    _failE:
        ld hl, expect.all.toBeUnclobbered.messageE
        jp zest.assertion.failed

    ; HL
    _failH:
        ld hl, expect.all.toBeUnclobbered.messageH
        jp zest.assertion.failed
    _failL:
        ld hl, expect.all.toBeUnclobbered.messageL
        jp zest.assertion.failed

    expect.all._toBeUnclobbered:
        ; Check if AF has been clobbered
        push hl
        push af
            ; Set HL to AF
            pop hl
            dec sp                  ; point stack back to AF value
            dec sp

            ; Check if A has been clobbered
            zest.test.loadAChecksum ; set A to the checksum value
            cp h                    ; compare "A"
            jr nz, _failA           ; jump if it's clobbered

            ; Check if F has been clobbered
            inc a                   ; set expected value
            cp l                    ; compare "F"
            jr nz, _failF           ; jump if it's clobbered

            ; Check if I has been clobbered
            add zest.utils.initRegisters.I_OFFSET - zest.utils.initRegisters.F_OFFSET
            ld h, a                 ; set H to expected value
            ld a, i                 ; set A to I
            cp h                    ; compare
            jr nz, _failI           ; jump if it's clobbered

            ; Set HL to AF'
            ex af, af'
                push af             ; push AF'
                pop hl              ; set HL to AF'
            ex af, af'              ; switch back

            ; Check if A' has been clobbered
            inc a                   ; set A to expected value
            cp h                    ; compare "A'"
            jr nz, _failShadowA

            ; Check if F' has been clobbered
            inc a                   ; set A to expected value
            cp l                    ; compare "F'"
            jr nz, _failShadowF
        pop af
        pop hl

        push af
            zest.test.loadAChecksum ; set A to the checksum value

            ; Check if B has been clobbered
            add zest.utils.initRegisters.B_OFFSET
            cp b                    ; compare
            jr nz, _failB           ; jump if it's clobbered

            ; Check if C has been clobbered
            inc a                   ; set expected value
            cp c                    ; compare
            jr nz, _failC           ; jump if it's clobbered

            ; Check if D has been clobbered
            inc a                   ; set expected value
            cp d                    ; compare
            jr nz, _failD           ; jump if it's clobbered

            ; Check if E has been clobbered
            inc a                   ; set expected value
            cp e                    ; compare
            jr nz, _failE           ; jump if it's clobbered

            ; Check if H has been clobbered
            inc a                   ; set expected value
            cp h                    ; compare
            jr nz, _failH           ; jump if it's clobbered

            ; Check if L has been clobbered
            inc a                   ; set expected value
            cp l                    ; compare
            jr nz, _failL           ; jump if it's clobbered

            ; Check if IXH has been clobbered
            inc a                   ; set expected value
            cp ixh                  ; compare
            jr nz, _failIXH         ; jump if it's clobbered

            ; Check if IXL has been clobbered
            inc a                   ; set expected value
            cp ixl                  ; compare
            jr nz, _failIXL         ; jump if it's clobbered

            ; Check if IYH has been clobbered
            inc a                   ; set expected value
            cp iyh                  ; compare
            jr nz, _failIYH         ; jump if it's clobbered

            ; Check if IYL has been clobbered
            inc a                   ; set expected value
            cp iyl                  ; compare
            jr nz, _failIYL         ; jump if it's clobbered

            ; Switch to shadow registers
            exx

            ; Check if B' has been clobbered
            add zest.utils.initRegisters.SHADOW_B_OFFSET - zest.utils.initRegisters.IYL_OFFSET
            cp b                    ; compare
            jr nz, _failShadowB     ; jump if it's clobbered

            ; Check if C' has been clobbered
            inc a                   ; set expected value
            cp c                    ; compare
            jr nz, _failShadowC     ; jump if it's clobbered

            ; Check if D' has been clobbered
            inc a                   ; set expected value
            cp d                    ; compare
            jr nz, _failShadowD     ; jump if it's clobbered

            ; Check if E' has been clobbered
            inc a                   ; set expected value
            cp e                    ; compare
            jr nz, _failShadowE     ; jump if it's clobbered

            ; Check if H' has been clobbered
            inc a                   ; set expected value
            cp h                    ; compare
            jr nz, _failShadowH     ; jump if it's clobbered

            ; Check if L' has been clobbered
            inc a                   ; set expected value
            cp l                    ; compare
            jr nz, _failShadowL     ; jump if it's clobbered

            ; Switch back from shadow registers
            exx
        pop af
        ret

    ; IX
    _failIXH:
        ld hl, expect.all.toBeUnclobbered.messageIXH
        jp zest.assertion.failed
    _failIXL:
        ld hl, expect.all.toBeUnclobbered.messageIXL
        jp zest.assertion.failed

    ; IY
    _failIYH:
        ld hl, expect.all.toBeUnclobbered.messageIYH
        jp zest.assertion.failed
    _failIYL:
        ld hl, expect.all.toBeUnclobbered.messageIYL
        jp zest.assertion.failed

    ; I
    _failI:
        ld hl, expect.all.toBeUnclobbered.messageI
        jp zest.assertion.failed

    ; Shadow AF
    _failShadowA:
        ld hl, expect.all.toBeUnclobbered.messageShadowA
        jp zest.assertion.failed
    _failShadowF:
        ld hl, expect.all.toBeUnclobbered.messageShadowF
        jp zest.assertion.failed

    ; Shadow BC
    _failShadowB:
        ld hl, expect.all.toBeUnclobbered.messageShadowB
        jp zest.assertion.failed
    _failShadowC:
        ld hl, expect.all.toBeUnclobbered.messageShadowC
        jp zest.assertion.failed

    ; Shadow DE
    _failShadowD:
        ld hl, expect.all.toBeUnclobbered.messageShadowD
        jp zest.assertion.failed
    _failShadowE:
        ld hl, expect.all.toBeUnclobbered.messageShadowE
        jp zest.assertion.failed

    ; Shadow HL
    _failShadowH:
        ld hl, expect.all.toBeUnclobbered.messageShadowH
        jp zest.assertion.failed
    _failShadowL:
        ld hl, expect.all.toBeUnclobbered.messageShadowL
        jp zest.assertion.failed
.ends

;====
; Assertion failure messages for each register
;====
.section "expect.all.toBeUnclobbered.message" free
    expect.all.toBeUnclobbered.messageA:
        zest.console.defineString "Expected A to be unclobbered"

    expect.all.toBeUnclobbered.messageB:
        zest.console.defineString "Expected B to be unclobbered"

    expect.all.toBeUnclobbered.messageC:
        zest.console.defineString "Expected C to be unclobbered"

    expect.all.toBeUnclobbered.messageD:
        zest.console.defineString "Expected D to be unclobbered"

    expect.all.toBeUnclobbered.messageE:
        zest.console.defineString "Expected E to be unclobbered"

    expect.all.toBeUnclobbered.messageH:
        zest.console.defineString "Expected H to be unclobbered"

    expect.all.toBeUnclobbered.messageL:
        zest.console.defineString "Expected L to be unclobbered"

    expect.all.toBeUnclobbered.messageIXH:
        zest.console.defineString "Expected IXH to be unclobbered"

    expect.all.toBeUnclobbered.messageIXL:
        zest.console.defineString "Expected IXL to be unclobbered"

    expect.all.toBeUnclobbered.messageIYH:
        zest.console.defineString "Expected IYH to be unclobbered"

    expect.all.toBeUnclobbered.messageIYL:
        zest.console.defineString "Expected IYL to be unclobbered"

    expect.all.toBeUnclobbered.messageI:
        zest.console.defineString "Expected I to be unclobbered"

    expect.all.toBeUnclobbered.messageF:
        zest.console.defineString "Expected Flags to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowA:
        zest.console.defineString "Expected A' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowF:
        zest.console.defineString "Expected F' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowB:
        zest.console.defineString "Expected B' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowC:
        zest.console.defineString "Expected C' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowD:
        zest.console.defineString "Expected D' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowE:
        zest.console.defineString "Expected E' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowH:
        zest.console.defineString "Expected H' to be unclobbered"

    expect.all.toBeUnclobbered.messageShadowL:
        zest.console.defineString "Expected L' to be unclobbered"
.ends
