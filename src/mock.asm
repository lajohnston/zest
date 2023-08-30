;====
; Structure for mock instances in RAM, which hold a counter for the times
; the mock has been called and the address to jump to to handle the
; mock logic
;====
.struct zest.Mock
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
    zest.mocks.startByte:   db
.ends

;====
; Marks the end of the mocks list
;====
.ramsection "zest.mocks.endByte" after zest.mocks
    zest.mocks.endByte:     db
.ends

;====
; Reserves space in RAM to store temporary opcodes for use when jumping to a
; mock handler without clobbing hl
;====
.ramsection "zest.mock.jump" slot zest.mapper.RAM_SLOT
    zest.mock.jump.pop:         db
    zest.mock.jump.jp:          db
    zest.mock.jump.jp_address:  dw
.ends

;====
; Variables
;====
.define zest.mock._mockStarted 0

;====
; Initialises all mocks
;====
.section "zest.mock.init"
    zest.mock.init:
        ; Get number of mocks
        ld a, (zest.mocks.endByte - zest.mocks.startByte - 1) / _sizeof_zest.Mock
        or a    ; update flags
        ret z   ; return if there are no mocks to clear

        ; Set B to number of mocks
        ld b, a

        ; Point to first mock (skipping start byte)
        ld hl, zest.mocks.startByte + 1

    _clearMock:
        ; Write 'push hl' instruction to Mock instance in RAM
        ld (hl), $e5

        ; Write 'call' instruction to Mock instance in RAM
        inc hl
        ld (hl), $cd

        ; Write mediator to Mock instance in RAM
        inc hl
        ld (hl), < zest.mock.mediator
        inc hl
        ld (hl), > zest.mock.mediator

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
    .ifndef mockAddress
        zest.utils.assert.fail "zest.mock.start expects a label argument that points to the mock"
    .endif

    zest.utils.assert.label mockAddress "zest.mock.start expects a label argument that points to the mock"

    .if zest.mock._mockStarted == 1
        zest.utils.assert.fail "Please ensure you've called the zest.mock.end macro at the end of your mock routines"
    .endif

    .redefine zest.mock._mockStarted 1

    push hl
        ld hl, \.\@
        ld (mockAddress + zest.Mock.address), hl
    pop hl

    jp zest.mock.end\@  ; jump over mock code, end label defined by zest.mock.end
    \.\@:               ; define start of the mock handler
.endm

;====
; Define the end of a mock handler
;====
.macro "zest.mock.end"
    .redefine zest.mock._mockStarted 0

    ret                 ; return from the handler
    zest.mock.end\@:    ; define end of the mock handler
.endm

;====
; A default mock handler that mocks run by default
;====
.section "zest.mock.defaultHandler" free
    zest.mock.defaultHandler:
        ret ; return to caller
.ends

;====
; Jumps to an address defined in RAM at runtime without clobbing hl.
; It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
; them from there so that control is passed to the destination code as if
; this mediator didn't exist, and so there's no need to have a pop hl instruction
; in the destination code
;
; @in   sp  the start address of the Zest mock in RAM
;====
.section "zest.mock.mediator" free
    zest.mock.mediator:
        ; Pop caller (mock) address from stack
        pop hl

        ; Increment mock's times_called counter
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
            ; this value was pushed by the mock (see zest.mock.init)
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
