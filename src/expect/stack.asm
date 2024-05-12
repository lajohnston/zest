;====
; Location to preserve registers without clobbing the stack
;====
.ramsection "expect.stack" slot zest.mapper.RAM_SLOT
    expect.stack.preservedHL: dw
    expect.stack.preservedDE: dw
.ends

;====
; Fails the test if the value in the stack doesn't match the expected value
;
; @in   expectedWord    the expected word value
; @in   offset          (optional) offset to the stack item
;                       0 = most recent; 1 = previous etc
; @in   message         (optional) custom message to display if the assertion fails
;====
.macro "expect.stack.toContain" isolated args expectedWord offset message
    zest.utils.assert.word expectedWord "\. expectedWord should be a 16-bit value"

    .ifdef offset
        zest.utils.assert.range offset 0 32 "\. offset should be between 0 and 32 inclusive"
    .endif

    \@_\..{expectedWord}:

    ; Navigate to stack position
    .ifdef offset
        .repeat offset
            inc sp
            inc sp
        .endr
    .endif

    ld (expect.stack.preservedDE), de   ; preserve DE
    pop de                              ; pop stack value into DE
    push af                             ; preserve AF in the same position

    ; Compare low byte
    ld a, <expectedWord
    cp e
    jr nz,  +                           ; jp if not equal

    ; Compare high byte
    ld a, >expectedWord
    cp d
    jr nz, +                            ; jp if not equal

    ; Assertion passed; Restore stack
    pop af                              ; restore AF
    push de                             ; restore original value to stack
    ld de, (expect.stack.preservedDE)   ; restore DE

    ; Restore stack pointer
    .ifdef offset
        .repeat offset
            dec sp
            dec sp
        .endr
    .endif

    jp ++   ; jump over assertion failed routine
        +:
            ; Assertion failed
            ld bc, expectedWord

            .ifdef message
                ld hl, \..customMessage.\@
            .else
                ld hl, expect.stack.toContain.defaultMessage
            .endif

            jp zest.runner.wordExpectationFailedV1

            .ifdef message
                \..customMessage.\@:
                    zest.console.defineString message
            .endif
    ++:
.endm

;====
; Compares the stack size to the starting to the test starting value and fails
; the test if it does not matched the expected value
;
; @in   expectedSize    the expected number of word values
; @in   message         (optional) the custom assertion-failed message
;====
.macro "expect.stack.size.toBe" isolated args expectedSize message
    zest.utils.assert.range expectedSize, 0, 40, "\. Invalid expectedSize argument"

    \@_\..{expectedSize}:
        ; Preserve registers without affecting stack
        ld (expect.stack.preservedDE), de   ; preserve DE in RAM
        ld (expect.stack.preservedHL), hl   ; preserve HL in RAM
        pop de                              ; preserve current stack value in DE
        push af                             ; preserve AF in stack

        ; Set HL to stack
        ld hl, 0
        add hl, sp

        ; Load A with stack size
        ld a, <zest.runner.DEFAULT_STACK_POINTER    ; low starting stack pointer
        sub l   ; subtract current low stack pointer
        rrca    ; divide by 2 (2-bytes per stack item)

        ; Compare with expected size
        cp expectedSize
        jp z, +
            ; Unexpected stack size
            ld b, expectedSize

            .ifdef message
                ld hl, \..customMessage.\@
            .else
                ld hl, expect.stack.size.toBe.defaultMessage
            .endif

            jp zest.runner.byteExpectationFailed

            .ifdef message
                \..customMessage.\@:
                    zest.console.defineString message
            .endif
        +:

        ; Assertion passed - restore registers and stack
        pop af                              ; restore AF
        push de                             ; restore current stack value
        ld de, (expect.stack.preservedDE)   ; restore DE
        ld hl, (expect.stack.preservedHL)   ; restore HL
.endm

;====
; The default expect.stack.toContain validation failure message
;====
.section "expect.stack.toContain.defaultMessage"
    expect.stack.toContain.defaultMessage:
        .asc "Unexpected value in stack"
        .db $ff ; terminator byte
.ends

;====
; The default expect.stack.size.toBe validation failure message
;====
.section "expect.stack.size.toBe.defaultMessage"
    expect.stack.size.toBe.defaultMessage:
        .asc "Unexpected stack size"
        .db $ff ; terminator byte
.ends