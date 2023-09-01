;====
; Structure for mock instances in RAM, which hold a counter for the times
; the mock has been called and the address to jump to to handle the
; mock logic
;====
.struct zest.Mock
    call_instruction    db
    call_address        dw
    times_called        db
    handler_address     dw
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
; Temporary location to preserve HL in the mediator without touching the stack
;====
.ramsection "zest.mocks.hlTemp" slot zest.mapper.RAM_SLOT
    zest.mock.hlTemp:     dw
.ends

;====
; Variables
;====
.define zest.mock._mockStarted 0

;====
; Initialises all mocks
;
; @clobs af
;====
.macro "zest.mock.initAll"
    ; Calculate number of mocks
    ld a, (zest.mocks.endByte - zest.mocks.startByte - 1) / _sizeof_zest.Mock

    ; Update flags
    or a

    ; Call initAll if there are more than 0 mocks
    call nz, zest.mock._initAll
.endm

;====
; (Private) Initialises/resets all the mock instances
;
; @in   a   the number of mock instances
;====
.section "zest.mock._initAll"
    zest.mock._initAll:
        ; Set B to number of mocks
        ld b, a

        ; Point to first mock (skipping start byte)
        ld hl, zest.mocks.startByte + 1

    _clearMock:
        ; Write 'call' instruction to Mock instance in RAM
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
        ld (mockAddress + zest.Mock.handler_address), hl
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
        ld (zest.mock.hlTemp), hl   ; preserve HL in temporary location

        ;==
        ; Set HL to the caller's (zest.Mock instance RAM instance) return address
        ; This will point to the mock's times_called value, after the call to
        ; this mediator
        ;==
        pop hl

        push af
            ; Increment mock's times_called counter
            inc (hl)
            jp nz, +
                ; Overflowed to 0 - cap at 255
                ld (hl), 255
            +:

            ; Set HL to handler
            inc hl      ; point to low byte of handler address
            ld a, (hl)  ; load low byte of handler into A
            inc hl      ; point to high byte of handler
            ld h, (hl)  ; load high byte of handler into H
            ld l, a     ; load low byte of handler into L
        pop af

        ; Restore HL and call the handler
        push hl                     ; push handler to stack
        ld hl, (zest.mock.hlTemp)   ; restore HL
        ret                         ; 'return' to the handler
.ends
