;====
; Asserts the value pointed at by the given register matches a given byte
;
; @in   hl              the pointer to assert
; @in   expectedValue   the expected value
; @in   message         (optional) custom assertion failure message
;====
.macro "expect.hl.toPointToByte" isolated args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a byte value"

    \@_\..{expectedValue}:

    ; Define custom message if given
     .if NARGS > 1
        zest.utils.validate.string message "\.: Message should be a string"

        jp +
            -:
            zest.console.defineString message
        +:
    .endif

    ; Call routine
    call expect.hl._toPointToByte

    ; Define expected byte immediately after call
    .db expectedValue

    ; Assertion message pointer
    .if NARGS == 1
        ; No message given - use default
        .dw expect.hl.toPointTo._defaultMessage
    .else
        ; Custom message given - pointer to inline message above
        .dw -
    .endif
.endm

;====
; Asserts the value pointed at by the given register matches a given word
;
; @in   hl              the pointer to assert
; @in   expectedValue   the expected value
; @in   message         (optional) custom assertion failure message
;====
.macro "expect.hl.toPointToWord" isolated args expectedValue message
    zest.utils.validate.word expectedValue "\. expects a word value"

    \@_\..{expectedValue}:

    ; Define custom message if given
     .if NARGS > 1
        zest.utils.validate.string message "\.: Message should be a string"

        jp +
            -:
            zest.console.defineString message
        +:
    .endif

    ; Call routine
    call expect.hl._toPointToWord

    ; Define expected byte immediately after call
    .dw expectedValue

    ; Assertion message pointer
    .if NARGS == 1
        ; No message given - use default
        .dw expect.hl.toPointTo._defaultMessage
    .else
        ; Custom message given - pointer to inline message above
        .dw -
    .endif
.endm

;====
; (Private) Asserts the value pointed at by the given register matches a given byte
;
; @in   hl      pointer to byte value to assert
;
; The data immediately following the call must adhere to the following format:
;
; .db   byte to assert
; .dw   pointer to assertion failure message
;====
.section "expect.hl._toPointToByte" free
    expect.hl._toPointToByte:
        ; Set HL to return address/assertion data after call
        ld (zest.assertion.tempWord), hl    ; preserve HL pointer
        ex (sp), hl

        push af
            ld a, (hl)  ; set A to expected byte
            push hl     ; preserve assertion data address
                ld hl, (zest.assertion.tempWord)    ; set HL to pointer
                cp (hl) ; compare expected/A with actual/(HL)
            pop hl      ; restore HL to return address/assertion data

            jr nz, _fail
        pop af

        ; Test passed; return to called after assertion data
        inc hl      ; skip expected byte
        inc hl      ; skip message
        inc hl      ; skip message
        ex (sp), hl ; restore HL; set return address to stack (now after assertion data)

        ret         ; return to caller after assertion data

        ;===
        ; Test failed
        ; @in       hl  pointer to assertion data
        ; @stack    original value for AF
        ;===
        _fail:
            push bc
            push de
                ld b, (hl)  ; set B to the expected byte
                inc hl      ; skip assertion byte

                ; Set HL to assertion message pointer
                ld a, (hl)
                inc hl
                ld h, (hl)
                ld l, a

                ld de, (zest.assertion.tempWord)    ; set DE to pointer address
                ld a, (de)                          ; set A to the actual value

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
            pop de
            pop bc
            pop af  ; pushed earlier

            ; Restore HL pointer
            ld hl, (zest.assertion.tempWord)

            jp zest.console.displayAndStop
.ends

;====
; (Private) Asserts the word pointed at by the given register matches a given
; word (little-endian)
;
; @in   hl      pointer to little-endian word to assert
;
; The data immediately following the call must adhere to the following format:
;
; .dw   word to assert
; .dw   pointer to assertion failure message
;====
.section "expect.hl._toPointToWord" free
    expect.hl._toPointToWord:
        ; Set HL to return address/assertion data after call
        ld (zest.assertion.tempWord), hl    ; preserve HL pointer
        ex (sp), hl

        push af
            ; Compare low byte
            ld a, (hl)  ; set A to expected low byte
            push hl     ; preserve assertion data address
                ld hl, (zest.assertion.tempWord)    ; set HL to pointer
                cp (hl) ; compare expected/A with actual/(HL)
            pop hl      ; restore HL to return address/assertion data

            jr nz, _fail

            ; Compare high byte
            inc hl      ; point to expected high byte
            ld a, (hl)  ; set A to expected high byte
            push hl     ; preserve assertion data address
                ld hl, (zest.assertion.tempWord)    ; set HL to pointer
                inc hl  ; point to actual high byte
                cp (hl) ; compare expected/A with actual/(HL)
            pop hl      ; restore HL to return address/assertion data

            dec hl      ; point back to expected low byte
            jr nz, _fail
        pop af

        ; Test passed; return to called after assertion data
        inc hl      ; skip expected high byte
        inc hl      ; skip message
        inc hl      ; skip message
        ex (sp), hl ; restore HL; set return address to stack (now after assertion data)

        ret         ; return to caller after assertion data

        ;===
        ; Test failed
        ; @in       hl  pointer to assertion data
        ; @stack    original value for AF
        ;===
        _fail:
            push bc
            push de
                ; Set BC to the expected word
                ld c, (hl)
                inc hl
                ld b, (hl)
                inc hl

                ; Set DE to pointer address
                ld de, (zest.assertion.tempWord)

                ; Print test description (describe and test blocks)
                call zest.assertion.printTestDescription

                ; Print assertion message
                ld a, (hl)
                inc hl
                ld h, (hl)
                ld l, a
                call zest.assertion.printMessage

                ; Print pointer address
                zest.console.newlines 2
                call zest.assertion.printAddressLabel
                call zest.console.outputHexDE

                ; Print expected value
                call zest.assertion.printExpectedLabel
                call zest.console.outputHexBC

                ; Print actual value
                ld a, (de)
                ld c, a
                inc de
                ld a, (de)
                ld b, a
                inc de

                call zest.assertion.printActualLabel
                call zest.console.outputHexBC
            pop de
            pop bc
            pop af  ; pushed earlier

            ; Restore HL pointer
            ld hl, (zest.assertion.tempWord)

            jp zest.console.displayAndStop
.ends

;====
; Assertion failure message
;====
.section "expect.rr.toPointTo._defaultMessage" free
    expect.hl.toPointTo._defaultMessage:
        zest.console.defineString "HL points to an unexpected value"
.ends
