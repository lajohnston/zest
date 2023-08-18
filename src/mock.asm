;====
; Structure for mock instances in RAM, which hold a counter for the times
; the mock has been called and the address to jump to to handle the
; mock logic
;====
.struct zest.mock
    push_hl             db
    call_instruction    db
    call_address        dw
    times_called        db
    address             dw
.endst

;====
; Start of mocks list. Mocks can be added by creating ramsections with
; "appendto zest.mocks", and populating them with zest.mock instances
;====
.ramsection "zest.mocks" slot zest.mapper.RAM_SLOT
    zest.mocks.start:    db
.ends

;====
; Marks the end of the mocks list
;====
.ramsection "zest.mocks.end" after zest.mocks
    zest.mocks.end:      db
.ends

.section "zest.mock.initAll"
    ;====
    ; Initialises one or more mocks in RAM
    ;====
    zest.mock.initAll:
        ; Get number of mocks
        ld a, (zest.mocks.end - zest.mocks.start - 1) / _sizeof_zest.mock
        or a    ; update flags
        ret z   ; return if there are no mocks to clear

        ; Point to first mock (skip start byte)
        ld hl, zest.mocks.start + 1
        ld b, a ; set B to number of mocks

    _clearMock:
        ; Add call mediator instructions to the mock instance
        ld (hl), $e5    ; write push hl to RAM
        inc hl
        ld (hl), $cd  ; write 'call' instruction to RAM
        inc hl
        ld (hl), < zest.mock.call
        inc hl
        ld (hl), > zest.mock.call

        ; Reset 'times called' counter
        inc hl
        ld (hl), 0

        ; Set default mock handler
        inc hl
        ld (hl), < zest.mock.defaultHandler
        inc hl
        ld (hl), > zest.mock.defaultHandler

        djnz _clearMock
        ret
.ends

;====
; Define the start of a mock handler. zest.mock.end must be called at the
; end of the handler
;
; @in   mockAddress the address of the mock instance to define the handler for
;====
.macro "zest.mock.start" args mockAddress
    push ix
        ld ix, mockAddress
        ld (ix + zest.mock.address), < _mockHandlerStart\@
        ld (ix + zest.mock.address + 1), > _mockHandlerStart\@
    pop ix

    jp _mockHandlerEnd\@    ; jump over mock code, end label defined by zest.mock.end
    _mockHandlerStart\@:    ; define start of the mock handler
.endm

;====
; Define the end of a mock handler
;====
.macro "zest.mock.end"
    ret                 ; return from the handler
    _mockHandlerEnd\@:  ; define end of the mock handler
.endm

;====
; Reserves space in RAM to store temporary opcodes for use when jumping to a
; mock handler without clobbing hl
;====
.ramsection "zest.mock.jump" slot zest.mapper.RAM_SLOT
    zest.mock.jump.pop:  db
    zest.mock.jump.jp:   db
    zest.mock.jump.jp_address:   dw
.ends

.section "zest.mock" free
    ;====
    ; Defines a procedure that mocks run by default
    ;====
    zest.mock.defaultHandler:
        ; by default, mocks just return to caller
        ret

    ;====
    ; Jumps to an address defined in RAM at runtime without clobbing hl.
    ; It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
    ; them from there so that control is passed to the destination code as if
    ; this mediator didn't exist, and so there's no need to have a pop hl instruction
    ; in the destination code
    ;
    ; @in   sp  the start address of the Zest mock in RAM
    ;====
    zest.mock.call:
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
            ; this value was pushed by the mock (see zest.mock.initAll)
            ld hl, zest.mock.jump.pop
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
        jp zest.mock.jump.pop
.ends
