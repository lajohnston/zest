;===================================================================
; Label mocks
;===================================================================

/**
 * Structure for mock instances in RAM, which hold a counter for the times
 * the mock has been called and the address to jump to to handle the
 * mock logic
 */
.struct smsspec.mock
    times_called    db
    address         dw
.endst


/**
 * Calls a handler for a mock, which is stored within the mock instance
 * in RAM.
 */
.macro "smsspec.mock.call" args mock
    push hl
        ld hl, mock
        jp smsspec.mock.mediator
    ; pop hl handled by mediator
.endm


/**
 * Set the destination address for a label mock
 */
.macro "smsspec.mock.set" args mock, address
    push hl
    push de
        ld de, address
        ld hl, mock
        inc hl
        ld (hl), e
        inc hl
        ld (hl), d
    pop de
    pop hl
.endm

/**
 * Define the start of a mock handler. smsspec.mock.end must be called at the
 * end of the handler
 *
 * @param   mockAddress the address of the mock instance to define the handler for
 */
.macro "smsspec.mock.start" args mockAddress
    smsspec.mock.set mockAddress, _mockHandlerStart\@
    jp _mockHandlerEnd\@    ; skip mock code until it is called
    _mockHandlerStart\@:    ; define start of the mock handler
.endm

/**
 * Define the end of a mock handler
 */
.macro "smsspec.mock.end"
    ret                 ; return from the handler
    _mockHandlerEnd\@:  ; define end of the mock handler
.endm

/**
 * Reserves space in RAM to store temporary opcodes for use when jumping to a
 * mock handler without clobbing hl
 */
.ramsection "smsspec.mock.jump" slot 2
    smsspec.mock.jump.pop:  db
    smsspec.mock.jump.jp:   db
    smsspec.mock.jump.jp_address:   dw
.ends

.section "smsspec.mock" free
    /**
     * Defines a procedure that mocks run by default
     */
    smsspec.mock.default_handler:
        ; by default, mocks just return to caller
        ret


    /**
     * Jumps to an address defined in RAM at runtime without clobbing hl.
     * It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
     * them from there so that control is passed to the destination code as if
     * this mediator didn't exist, and so there's no need to have a pop hl instruction
     * in the destination code
     *
     * @param hl    the start address of the smsspec mock in RAM
     */
    smsspec.mock.mediator:
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
            ld hl, smsspec.mock.jump.pop
            ld (hl), $E1    ; $E1 = pop hl

            ; Write jp opcode to RAM
            inc hl
            ld (hl), $C3    ; $C3 = jp, n

            ; Write jump address to RAM
            inc hl
            ld (hl), e
            inc hl
            ld (hl), d
        pop de

        ; Jump to opcodes in RAM
        jp smsspec.mock.jump.pop
.ends
