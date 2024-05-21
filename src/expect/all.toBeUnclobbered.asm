;====
; Assertions to ensure the expected registers haven't been clobbered
;====

;====
; A list of registers that are expected to be clobbered
;====
.struct "expect.all.toBeUnclobbered.ignoreList"
    main:   db
    shadow: db
    index:  db
.endst

;====
; Constants
;====

; High byte = ignoreList byte
; Low byte = bit within ignoreList byte
.define expect.all.toBeUnclobbered_A = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 0
.define expect.all.toBeUnclobbered_F = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 1
.define expect.all.toBeUnclobbered_B = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 2
.define expect.all.toBeUnclobbered_C = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 3
.define expect.all.toBeUnclobbered_D = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 4
.define expect.all.toBeUnclobbered_E = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 5
.define expect.all.toBeUnclobbered_H = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 6
.define expect.all.toBeUnclobbered_L = (expect.all.toBeUnclobbered.ignoreList.main << 8) + 7

.define expect.all.toBeUnclobbered_SHADOW_A = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 0
.define expect.all.toBeUnclobbered_SHADOW_F = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 1
.define expect.all.toBeUnclobbered_SHADOW_B = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 2
.define expect.all.toBeUnclobbered_SHADOW_C = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 3
.define expect.all.toBeUnclobbered_SHADOW_D = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 4
.define expect.all.toBeUnclobbered_SHADOW_E = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 5
.define expect.all.toBeUnclobbered_SHADOW_H = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 6
.define expect.all.toBeUnclobbered_SHADOW_L = (expect.all.toBeUnclobbered.ignoreList.shadow << 8) + 7

.define expect.all.toBeUnclobbered_IXH = (expect.all.toBeUnclobbered.ignoreList.index << 8) + 0
.define expect.all.toBeUnclobbered_IXL = (expect.all.toBeUnclobbered.ignoreList.index << 8) + 1
.define expect.all.toBeUnclobbered_IYH = (expect.all.toBeUnclobbered.ignoreList.index << 8) + 2
.define expect.all.toBeUnclobbered_IYL = (expect.all.toBeUnclobbered.ignoreList.index << 8) + 3
.define expect.all.toBeUnclobbered_I = (expect.all.toBeUnclobbered.ignoreList.index << 8) + 4

;====
; Compares all registers to the initial values set by zest.initRegisters, and
; fails the test if any values have changed
;====
.macro "expect.all.toBeUnclobbered"
    call expect.all._toBeUnclobberedExcept
    .repeat _sizeof_expect.all.toBeUnclobbered.ignoreList
        .db 0   ; ignore none
    .endr
.endm

;====
; Like expect.all.toBeUnclobbered but with a list of registers to ignore, i.e
; expect.all.toBeUnclobberedExcept "a" "b" "a'"
;====
.macro "expect.all.toBeUnclobberedExcept"
    ; Register group ignore lists
    .redefine \..ignoreMain     0
    .redefine \..ignoreShadow   0
    .redefine \..ignoreIndex    0

    .repeat nargs
        .redefine \..register \1

        .ifdef \..parsedRegister2
            .undefine \..parsedRegister2
        .endif

        .if \..register == "a"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_A
        .elif \..register == "f"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_F
        .elif \..register == "b"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_B
        .elif \..register == "c"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_C
        .elif \..register == "d"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_D
        .elif \..register == "e"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_E
        .elif \..register == "h"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_H
        .elif \..register == "l"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_L
        .elif \..register == "a'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_A
        .elif \..register == "f'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_F
        .elif \..register == "b'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_B
        .elif \..register == "c'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_C
        .elif \..register == "d'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_D
        .elif \..register == "e'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_E
        .elif \..register == "h'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_H
        .elif \..register == "l'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_L
        .elif \..register == "ixh"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IXH
        .elif \..register == "ixl"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IXL
        .elif \..register == "iyh"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IYH
        .elif \..register == "iyl"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IYL
        .elif \..register == "i"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_I
        .elif \..register == "af"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_A
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_F
        .elif \..register == "bc"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_B
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_C
        .elif \..register == "de"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_D
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_E
        .elif \..register == "hl"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_H
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_L
        .elif \..register == "ix"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IXH
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_IXL
        .elif \..register == "iy"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_IYH
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_IYL
        .elif \..register == "af'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_A
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_F
        .elif \..register == "bc'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_B
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_C
        .elif \..register == "de'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_D
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_E
        .elif \..register == "hl'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_H
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_L
        .elif \..register == "ix'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_IXH
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_IXL
        .elif \..register == "iy'"
            .redefine \..parsedRegister expect.all.toBeUnclobbered_SHADOW_IYH
            .redefine \..parsedRegister2 expect.all.toBeUnclobbered_SHADOW_IYL
        .else
            .print "\.: Unknown register ", \1, "\n"
            .fail
        .endif

        ; Add register to the relevant ignore list variable
        .redefine \..bit <(\..parsedRegister)
        .redefine \..list >(\..parsedRegister)

        .if \..list == expect.all.toBeUnclobbered.ignoreList.main
            .redefine \..ignoreMain (\..ignoreMain | 1 << \..bit)

            .ifdef \..parsedRegister2
                .redefine \..ignoreMain (\..ignoreMain | 1 << <(\..parsedRegister2))
            .endif
        .elif \..list == expect.all.toBeUnclobbered.ignoreList.shadow
            .redefine \..ignoreShadow (\..ignoreShadow | 1 << \..bit)

            .ifdef \..parsedRegister2
                .redefine \..ignoreShadow (\..ignoreShadow | 1 << <(\..parsedRegister2))
            .endif
        .elif \..list == expect.all.toBeUnclobbered.ignoreList.index
            .redefine \..ignoreIndex (\..ignoreIndex | 1 << \..bit)

            .ifdef \..parsedRegister2
                .redefine \..ignoreIndex (\..ignoreIndex | 1 << <(\..parsedRegister2))
            .endif
        .endif

        .shift  ; /2 becomes /1
    .endr

    ; Call assertion routine
    call expect.all._toBeUnclobberedExcept

    ; Define ignoreList instance data directly after call
    .db \..ignoreMain
    .db \..ignoreShadow
    .db \..ignoreIndex
.endm

;====
; Indicates if the given register is on the clobber ignore list
;
; @in   ix          pointer to the ignoreList instance
; @in   register    expect.all.toBeUnclobbered_x constant
; @out  f           nz if the register should be ignored, otherwise z
;====
.macro "expect.all.toBeUnclobbered._isIgnoredIX" args register
    .redefine \..bit <(register)
    .redefine \..list >(register)

    bit <(\..bit), (ix + \..list)
.endm

;====
; (Private) See expect.all.toBeUnclobbered macro
;====
.section "expect.all._toBeUnclobberedExcept" free
    ; AF
    _failA:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_A
        jr nz, _postACheck

        ld hl, expect.all.toBeUnclobbered.messageA
        jp zest.assertion.failed

    _failF:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_F
        jr nz, _postFCheck

        ld hl, expect.all.toBeUnclobbered.messageF
        jp zest.assertion.failed

    ; I
    _failI:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_I
        jr nz, _postICheck

        ld hl, expect.all.toBeUnclobbered.messageI
        jp zest.assertion.failed

    ; Shadow AF
    _failShadowA:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_A
        jr nz, _postShadowACheck

        ld hl, expect.all.toBeUnclobbered.messageShadowA
        jp zest.assertion.failed
    _failShadowF:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_F
        jr nz, _postShadowFCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowF
        jp zest.assertion.failed

    ; DE
    _failD:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_D
        jr nz, _postDCheck

        ld hl, expect.all.toBeUnclobbered.messageD
        jp zest.assertion.failed
    _failE:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_E
        jr nz, _postECheck

        ld hl, expect.all.toBeUnclobbered.messageE
        jp zest.assertion.failed

    ; HL
    _failH:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_H
        jr nz, _postHCheck

        ld hl, expect.all.toBeUnclobbered.messageH
        jp zest.assertion.failed
    _failL:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_L
        jr nz, _postLCheck

        ld hl, expect.all.toBeUnclobbered.messageL
        jp zest.assertion.failed

    expect.all._toBeUnclobberedExcept:
        ; Preserve IX on stack and set IX to the ignoreList pointer
        ex (sp), ix

        push hl
        push af
            ; Set HL to AF
            pop hl
            dec sp                  ; point stack back to AF value
            dec sp

            ; Check if A has been clobbered
            zest.test.loadAChecksum ; set A to the expected value
            cp h                    ; compare "A"
            jr nz, _failA           ; jump if it's clobbered
            _postACheck:

            ; Check if F has been clobbered
            inc a                   ; set A to expected value
            cp l                    ; compare "F"
            jr nz, _failF           ; jump if it's clobbered
            _postFCheck:

            ; Check if I has been clobbered
            add zest.utils.initRegisters.I_OFFSET - zest.utils.initRegisters.F_OFFSET
            ld h, a                 ; set H to expected value
                ld a, i             ; set A to I
                cp h                ; compare with expected value
                jr nz, _failI       ; jump if it's clobbered
                _postICheck:
            ld a, h                 ; set A to expected value

            ; Set HL to AF'
            ex af, af'
                push af             ; push AF'
                pop hl              ; set HL to AF'
            ex af, af'              ; switch back

            ; Check if A' has been clobbered
            inc a                   ; set A to expected value
            cp h                    ; compare "A'"
            jr nz, _failShadowA
            _postShadowACheck:

            ; Check if F' has been clobbered
            inc a                   ; set A to expected value
            cp l                    ; compare "F'"
            jr nz, _failShadowF
            _postShadowFCheck:
        pop af
        pop hl

        push af
            zest.test.loadAChecksum ; set A to the checksum value

            ; Check if B has been clobbered
            add zest.utils.initRegisters.B_OFFSET
            cp b                    ; compare
            jr nz, _failB           ; jump if it's clobbered
            _postBCheck:

            ; Check if C has been clobbered
            inc a                   ; set expected value
            cp c                    ; compare
            jr nz, _failC           ; jump if it's clobbered
            _postCCheck:

            ; Check if D has been clobbered
            inc a                   ; set expected value
            cp d                    ; compare
            jr nz, _failD           ; jump if it's clobbered
            _postDCheck:

            ; Check if E has been clobbered
            inc a                   ; set expected value
            cp e                    ; compare
            jr nz, _failE           ; jump if it's clobbered
            _postECheck:

            ; Check if H has been clobbered
            inc a                   ; set expected value
            cp h                    ; compare
            jr nz, _failH           ; jump if it's clobbered
            _postHCheck:

            ; Check if L has been clobbered
            inc a                   ; set expected value
            cp l                    ; compare
            jr nz, _failL           ; jump if it's clobbered
            _postLCheck:

            ; Check if IYH has been clobbered
            add zest.utils.initRegisters.IYH_OFFSET - zest.utils.initRegisters.L_OFFSET
            cp iyh                  ; compare
            jr nz, _failIYH         ; jump if it's clobbered
            _postIYHCheck:

            ; Check if IYL has been clobbered
            inc a                   ; set expected value
            cp iyl                  ; compare
            jr nz, _failIYL         ; jump if it's clobbered
            _postIYLCheck:

            ; Switch to shadow registers
            exx

            ; Check if B' has been clobbered
            add zest.utils.initRegisters.SHADOW_B_OFFSET - zest.utils.initRegisters.IYL_OFFSET
            cp b                    ; compare
            jr nz, _failShadowB     ; jump if it's clobbered
            _postShadowBCheck:

            ; Check if C' has been clobbered
            inc a                   ; set expected value
            cp c                    ; compare
            jr nz, _failShadowC     ; jump if it's clobbered
            _postShadowCCheck:

            ; Check if D' has been clobbered
            inc a                   ; set expected value
            cp d                    ; compare
            jp nz, _failShadowD     ; jump if it's clobbered
            _postShadowDCheck:

            ; Check if E' has been clobbered
            inc a                   ; set expected value
            cp e                    ; compare
            jp nz, _failShadowE     ; jump if it's clobbered
            _postShadowECheck:

            ; Check if H' has been clobbered
            inc a                   ; set expected value
            cp h                    ; compare
            jp nz, _failShadowH     ; jump if it's clobbered
            _postShadowHCheck:

            ; Check if L' has been clobbered
            inc a                   ; set expected value
            cp l                    ; compare
            jp nz, _failShadowL     ; jump if it's clobbered
            _postShadowLCheck:

            ; Switch back from shadow registers
            exx
        pop af

        ; Set A to index ignore list
        ld (zest.runner.tempWord), a    ; preserve without adjusting stack
            ld a, (ix + expect.all.toBeUnclobbered.ignoreList.index)

            ; Skip the ignoreList data in the return address
            .repeat _sizeof_expect.all.toBeUnclobbered.ignoreList
                inc ix
            .endr

            ex (sp), ix                 ; restore IX; set stack to return address

            push af
            push bc
                ld b, a                 ; set B to index ignore list
                zest.test.loadAChecksum ; set A to the checksum value

                ; Check if IXH has been clobbered
                add zest.utils.initRegisters.IXH_OFFSET - zest.utils.initRegisters.A_OFFSET
                cp ixh                  ; compare
                jp nz, _failIXH         ; jump if it's clobbered
                _postIXHCheck:

                ; Check if IXL has been clobbered
                inc a
                cp ixl                  ; compare
                jp nz, _failIXL         ; jump if it's clobbered
                _postIXLCheck:
            pop bc
            pop af
            ; ld hl, (zest.runner.)
        ld a, (zest.runner.tempWord)
        ret

    ; BC
    _failB:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_B
        jr nz, _postBCheck

        ld hl, expect.all.toBeUnclobbered.messageB
        jp zest.assertion.failed
    _failC:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_C
        jr nz, _postCCheck

        ld hl, expect.all.toBeUnclobbered.messageC
        jp zest.assertion.failed

    ; IY
    _failIYH:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_IYH
        jp nz, _postIYHCheck

        ld hl, expect.all.toBeUnclobbered.messageIYH
        jp zest.assertion.failed
    _failIYL:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_IYL
        jp nz, _postIYLCheck

        ld hl, expect.all.toBeUnclobbered.messageIYL
        jp zest.assertion.failed

    ; Shadow BC
    _failShadowB:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_B
        jr nz, _postShadowBCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowB
        jp zest.assertion.failed
    _failShadowC:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_C
        jp nz, _postShadowCCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowC
        jp zest.assertion.failed

    ; Shadow DE
    _failShadowD:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_D
        jp nz, _postShadowDCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowD
        jp zest.assertion.failed
    _failShadowE:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_E
        jp nz, _postShadowECheck

        ld hl, expect.all.toBeUnclobbered.messageShadowE
        jp zest.assertion.failed

    ; Shadow HL
    _failShadowH:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_H
        jp nz, _postShadowHCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowH
        jp zest.assertion.failed
    _failShadowL:
        ; Continue if this register is on the exception list
        expect.all.toBeUnclobbered._isIgnoredIX expect.all.toBeUnclobbered_SHADOW_L
        jp nz, _postShadowLCheck

        ld hl, expect.all.toBeUnclobbered.messageShadowL
        jp zest.assertion.failed

    ; IX
    _failIXH:
        ; Continue if this register is on the exception list
        bit <(expect.all.toBeUnclobbered_IXH), b
        jp nz, _postIXHCheck

        ld hl, expect.all.toBeUnclobbered.messageIXH
        jp zest.assertion.failed
    _failIXL:
        ; Continue if this register is on the exception list
        bit <(expect.all.toBeUnclobbered_IXL), b
        jp nz, _postIXLCheck

        ld hl, expect.all.toBeUnclobbered.messageIXL
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
