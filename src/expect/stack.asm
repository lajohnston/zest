;====
; Assertions for items in the stack
;====

;====
; Constants
;====
.define expect.stack.TEMP_STACK_SIZE_BYTES 4

;====
; Location to preserve registers without clobbing the stack
;====
.ramsection "expect.stack" slot zest.mapper.RAM_SLOT
    expect.stack.originalSP:  dw

    ; Temporary stack, to preserve contents of main stack
    expect.stack.tempStack:   dsb expect.stack.TEMP_STACK_SIZE_BYTES
.ends

;====
; Switches to a temporary stack, so calls and push/pops don't clobber the main
; stack
;====
.macro "expect.stack._switchToTempStack"
    ; Switch to temporary stack
    ld (expect.stack.originalSP), sp    ; preserve original stack pointer
    ld sp, expect.stack.tempStack + expect.stack.TEMP_STACK_SIZE_BYTES
.endm

;====
; Switches back to the main stack after a call to expect.stack._switchToTempStack
;====
.macro "expect.stack._switchToMainStack"
    ld sp, (expect.stack.originalSP)
.endm

;====
; Fails the test if the value in the stack doesn't match the expected value
;
; @in   expectedWord    the expected word value
; @in   offset          (optional) offset to the stack item
;                       0 = most recent; 1 = previous etc
; @in   message         (optional) custom message to display if the assertion fails
;====
.macro "expect.stack.toContain" isolated args expectedWord offset message
    zest.utils.validate.word expectedWord "\. expectedWord should be a 16-bit value"

    .ifdef offset
        zest.utils.validate.range offset 0 32 "\. offset should be between 0 and 32 inclusive"
    .else
        .define offset 0
    .endif

    \@_\..{expectedWord}:

    ; Define custom message
    .ifdef message
        zest.utils.validate.string message "\.: Message should be a string value"

        jr +
            \.\@messagePointer:
                zest.console.defineString message
        +:
    .endif

    ; Switch to temporary stack
    expect.stack._switchToTempStack

    ; Call assertion routine and define assertion data immediately after
    call expect.stack._toContain
    .db offset
    .dw expectedWord
    .ifdef message
        .dw \.\@messagePointer
    .else
        .dw expect.stack.toContain.defaultMessage
    .endif

    ; Test passed; Restore stack pointer
    expect.stack._switchToMainStack
.endm

;====
; (Private) Fails the test if the stack does not contain the expected word at
; the given offset
;
; @in   stack{0}    pointer to assertion data (defined immediately after call)
;                       2 bytes - expected word
;                       2 bytes - pointer to failure message
;====
.section "expect.stack._toContain" free
    expect.stack._toContain:
        ; Set HL to assertion data pointer; preserve HL on stack
        ex hl, (sp)

        ; Set DE to original stack
        ld (zest.runner.tempWord), de       ; preserve DE
        ld de, (expect.stack.originalSP)    ; set DE to original stack pointer

        push af
            ld a, (hl)  ; set A to offset
            rlca        ; * 2 (2 bytes per stack entry)

            ; Add offset to stack pointer
            add a, e    ; A = A+E
            ld e, a     ; E = A+E
            adc a, d    ; A = A+E+D+carry
            sub e       ; A = D+carry
            ld d, a     ; D = D+carry

            inc hl      ; point HL to expected value
            ex de, hl   ; set HL to stack pointer and DE to expected word
                ; Compare low byte
                ld a, (de)              ; set A to expected low byte
                cp (hl)                 ; compare with actual low byte
                jr nz, _fail            ; jp if not equal

                ; Compare high byte
                inc de                  ; point to expected high byte
                inc hl                  ; point to actual high byte
                ld a, (de)              ; set A to expected high byte
                cp (hl)                 ; compare with actual low byte
                jr nz, _failHighByte    ; jp if high byte was not equal
            ex de, hl

            ; Restore DE
            ld de, (zest.runner.tempWord)

            ; Skip over assertion data in return address
            inc hl  ; skip expect value (high byte)
            inc hl  ; skip message pointer
            inc hl
        pop af

        ex (sp), hl ; restore HL and set return address to temp stack
        ret

    _failHighByte:
        ; Restore pointers to low bytes
        dec de
        dec hl
        ; continue to _fail

    _fail:
        ; Restore SP
        expect.stack._switchToMainStack

        ; Set IX to assertion data + message pointer
        push de
        pop ix

        ; Set DE to actual value
        ld e, (hl)
        inc hl
        ld d, (hl)

        jp zest.assertion.word.failed
.ends

;====
; Compares the stack size to the starting to the test starting value and fails
; the test if it does not matched the expected value
;
; @in   expectedSize    the expected number of word values
; @in   message         (optional) the custom assertion-failed message
;====
.macro "expect.stack.size.toBe" isolated args expectedSize message
    zest.utils.validate.range expectedSize, 0, 40, "\. Invalid expectedSize argument"

    ; Define custom message
    .ifdef message
        zest.utils.validate.string message "\.: Message should be a string value"

        jr +
            \.\@messagePointer:
                zest.console.defineString message
        +:
    .endif

    \@_\..{expectedSize}:
        ; Switch to temporary stack
        expect.stack._switchToTempStack

        ; Call assertion and define assertion data directly after
        call expect.stack.size._toBe
        .db expectedSize
        .ifdef message
            .dw \.\@messagePointer
        .else
            .dw expect.stack.toContain.defaultMessage
        .endif

        ; Restore SP
        expect.stack._switchToMainStack
.endm

;====
; (Private) Fails the test if the stack isn't x words larger than the default
;
; @in   stack{0}    pointer to assertion data (defined immediately after call)
;                       1 byte  - expected stack size in words
;                       2 bytes - pointer to failure message
;====
.section "expect.stack.size._toBe" free
    expect.stack.size._toBe:
        ex (sp), hl
        push af
            ; Get diff between expected and actual low byte of SP
            ld a, (expect.stack.originalSP) ; set A to actual low byte of SP
            sub <(zest.runner.DEFAULT_STACK_POINTER)    ; sub starting pointer

            ; Convert to size in words
            neg     ; negate
            rrca    ; divide by 2 (2 bytes per stack entry)

            cp (hl)         ; compare with expected size
            jp nz, _fail    ; jp if it isn't equal
        pop af

        ; Calculate return address (skip assertion data)
        inc hl
        inc hl
        inc hl
        ex (sp), hl ; restore HL; set return address to stack
        ret

    _fail:
        ; Restore stack pointer
        expect.stack._switchToMainStack

        ; Set IX to assertion data pointer
        push hl
        pop ix

        ; A = actual value; IX = pointer to assertion data
        jp zest.assertion.byte.failed
.ends

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
