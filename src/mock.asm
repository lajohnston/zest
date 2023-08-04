;====
; Structure for mock instances in RAM, which hold a counter for the times
; the mock has been called and the address to jump to to handle the
; mock logic
;====
.struct smsspec.mock
    push_hl             db
    call_instruction    db
    call_address        dw
    times_called        db
    address             dw
.endst

.section "smsspec.mock.initAll"
    ;====
    ; Initialises one or more mocks in RAM
    ;
    ; @in hl    the address of the first mock in RAM
    ; @in b     the number of mocks to initialise
    ;====
    smsspec.mock.initAll:
        ; Add call mediator instructions to the mock instance
        ld (hl), $e5    ; write push hl to RAM
        inc hl
        ld (hl), $cd  ; write 'call' instruction to RAM
        inc hl
        ld (hl), < smsspec.mock.call
        inc hl
        ld (hl), > smsspec.mock.call

        ; Reset 'times called' counter
        inc hl
        ld (hl), 0

        ; Set default mock handler
        inc hl
        ld (hl), < smsspec.mock.defaultHandler
        inc hl
        ld (hl), > smsspec.mock.defaultHandler

        djnz smsspec.mock.initAll
        ret
.ends

;====
; Define the start of a mock handler. smsspec.mock.end must be called at the
; end of the handler
;
; @in   mockAddress the address of the mock instance to define the handler for
;====
.macro "smsspec.mock.start" args mockAddress
    push ix
        ld ix, mockAddress
        ld (ix + smsspec.mock.address), < _mockHandlerStart\@
        ld (ix + smsspec.mock.address + 1), > _mockHandlerStart\@
    pop ix

    jp _mockHandlerEnd\@    ; jump over mock code, end label defined by smsspec.mock.end
    _mockHandlerStart\@:    ; define start of the mock handler
.endm

;====
; Define the end of a mock handler
;====
.macro "smsspec.mock.end"
    ret                 ; return from the handler
    _mockHandlerEnd\@:  ; define end of the mock handler
.endm

;====
; Reserves space in RAM to store temporary opcodes for use when jumping to a
; mock handler without clobbing hl
;====
.ramsection "smsspec.mock.jump" slot 2
    smsspec.mock.jump.pop:  db
    smsspec.mock.jump.jp:   db
    smsspec.mock.jump.jp_address:   dw
.ends

.section "smsspec.mock" free
    ;====
    ; Defines a procedure that mocks run by default
    ;====
    smsspec.mock.defaultHandler:
        ; by default, mocks just return to caller
        ret

    ;====
    ; Jumps to an address defined in RAM at runtime without clobbing hl.
    ; It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
    ; them from there so that control is passed to the destination code as if
    ; this mediator didn't exist, and so there's no need to have a pop hl instruction
    ; in the destination code
    ;
    ; @in   sp  the start address of the smsspec mock in RAM
    ;====
    smsspec.mock.call:
        ; pop caller (mock) address from stack
        pop hl

        ; Increment mock's times_called counter in RAM
        push af
            inc (hl)
            ; TODO - add overflow logic
        pop af

        push de
            ; Load address of mock handler from RAM into DE
            inc hl
            ld e, (hl)
            inc hl
            ld d, (hl)

            ; To jump to handler without clobbing hl, write a couple of instructions
            ; to RAM which will pop hl then jp to the address

            ; Write 'pop hl' opcode to RAM
            ; this value was pushed by the mock, see smsspec.mock.initAll
            ld hl, smsspec.mock.jump.pop
            ld (hl), $e1    ; $e1 = pop hl

            ; Write jp opcode to RAM
            inc hl
            ld (hl), $c3    ; $c3 = jp, n

            ; Write jump address to RAM
            inc hl
            ld (hl), e
            inc hl
            ld (hl), d
        pop de

        ; Jump to opcodes in RAM
        jp smsspec.mock.jump.pop
.ends
