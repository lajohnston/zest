;====
; Asserts the given pointer address points to an expected sequence of data
;
; @in   \1  start address
; @in   ... sequence of one or more bytes
;====
.macro "expect.address.toContain"
    .if NARGS < 2
        zest.utils.validate.fail "\. expects at least 2 args"
    .endif

    \@_\.:

    call expect.address._toContain

    ; Assertion data defined immediately after call
    .dw \1          ; start pointer address
    .shift          ; shift args
    .db NARGS       ; number of assertion bytes

    ; Define sequence bytes
    .repeat NARGS
        zest.utils.validate.byte \1 "\. expects a sequence of numeric bytes"
        .db \1
        .shift
    .endr
.endm

;====
; (Private) Prints to the console a message explaining the failed assertion
;
; @in   a   the actual value
; @in   b   the expected value
; @in   hl  pointer to assertion message
; @in   de  address of failed value
;====
.macro "expect.address.toContain._printFailedMessage"
    ; Print test description (describe and test blocks)
    call zest.assertion.printTestDescription

    ; Print assertion message
    call zest.assertion.printMessage

    ; Print pointer address
    zest.console.newlines 2
    call zest.assertion.printAddressLabel
    call zest.console.outputHexDE

    ; Print expected value
    call zest.assertion.printExpectedLabel
    call zest.console.outputHexB

    ; Print actual value
    call zest.assertion.printActualLabel
    call zest.console.outputHexA

    jp zest.console.displayAndStop
.endm

;====
; (Private) Asserts the sequence of bytes pointed at by DE matches the given
; sequence of bytes
;
; The data immediately following the call must adhere to the following format:
;
; .dw   start address
; .db   number of bytes to assert (1-255)
; .dsb  expected byte values
;====
.section "expect.address._toContain" free
    expect.address._toContain:
        ; Swap HL with the return value in the stack (pointer to assertion data)
        ex (sp), hl
        ld (zest.assertion.tempWord), hl    ; preserve pointer to assertion data

        push af
        push bc
        push de
            ; Load pointer into DE
            ld e, (hl)  ; low byte
            inc hl
            ld d, (hl)  ; high byte
            inc hl

            ; Load byte count into BC
            ld b, 0
            ld c, (hl)
            inc hl      ; point HL to first byte of expected data

            ; Compare (HL/expected) with (DE/actual)
            -:
                ld a, (de)      ; load A with next actual byte
                cpi             ; cp with expected (cp a, inc hl, dec bc)
                jr nz, _failed  ; jp if not equal
                inc de          ; inc DE/actual pointer
            jp pe, -            ; loop until BC counter is zero

            jp _passed          ; jp when all bytes equal

            ;===
            ; @in   a   actual byte
            ; @in   hl  (pointer to failed assertion byte) + 1
            ; @in   de  pointer to actual byte
            ;===
            _failed:
                dec hl      ; point HL back to failed assertion byte
                ld b, (hl)  ; set B to failed assertion byte

                ; Set HL to assertion message point - ld hl, (hl)
                ld hl, expect.address.toContain.defaultMessage
                expect.address.toContain._printFailedMessage

        _passed:

        pop de
        pop bc
        pop af

        ex (sp), hl         ; restore HL and return address on stack

        ret
.ends

;====
; Assertion failure message
;====
.section "expect.address.toContain.defaultMessage" free
    expect.address.toContain.defaultMessage:
        zest.console.defineString "Unexpected value at address"
.ends
