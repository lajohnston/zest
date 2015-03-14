;==============================================================
; SMS defines
;==============================================================
.define Ports.Vdp.Control $bf
.define Ports.Vdp.Data $be
.define Ports.Vdp.Status $be ; same as Vdp.Data, as that is write only and this is read only
.define Vdp.VRAMWrite $4000
.define Vdp.CRAMWrite $c000

;==============================================================
; WLA-DX banking setup
; Allows 32KB ROM (starts at 0, ends at $8000 bytes)
;==============================================================
.memorymap
    defaultslot 0
    slotsize $8000
    slot 0 $0000
.endme

.rombankmap
    bankstotal 1
    banksize $8000
    banks 1
.endro


; SDSC tag and SMS rom header
.sdsctag 1.2,"SMSSpec", "Sega Master System Unit Test Runner", "eljay"


/**
 * Pause button handler
 */
.bank 0 slot 0
.orga $0066
retn


/**
 * VBlank handler
 */
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (Ports.Vdp.Status) ; satisfy interrupt
        call smsspec.onVBlank
    pop af
    ei
    reti
.ends


/**
 * Start runner
 */
.orga $0000
call smsspec.suite
-: jp -



;===================================================================
; Assertion and test macros
;===================================================================


/**
 * Can be used to describe the unit being tested
 */
.macro "describe" args unit_name

.endm

/**
 * Specified a new test with a description.
 * Resets the Z80 registers ready for the new test
 */
.macro "it" args message
    ; Write message to buffer

    ; Clear system state
    call smsspec.clearSystemState
.endm


.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        assertionFailed "Failed"
    +:
.endm


/*
.macro "assertRegisterEquals" args expected, register
    push af
        ld a, register
        cp expected
        
        jr z, +
            pop af
            assertionFailed "Failed"
        +:
    pop af
.endm
 */


.macro "assertionFailed" args message, actual
    jp assertionFailed
.endm








;===================================================================
; SMSSpec internal procedures
;===================================================================

.section "smsspec.clearSystemState" free
    smsspec.clearSystemState:
        xor a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a

        ; reset fps counter

        ; do same for shadow flags 
        
        ret       
.ends

.section "smsspec.console" free
    smsspec.console.out:
        ret
.ends

.section "smsspec.onVBlank" free
    smsspec.onVBlank:
        ret
.ends

.section "on failure" free
    assertionFailed:
        call smsspec.console.out
        -: jp -
.ends



;===================================================================
; Import user's test suite file
;===================================================================
smsspec.suite:
    .include "test_suite.asm"
    ret
