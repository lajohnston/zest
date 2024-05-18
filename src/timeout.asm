;====
; Manages a frame counter in RAM
;====

;====
; Settings
;====

; Default timeout (in full frames) for tests. Should be between 1 and 255
.ifndef zest.defaultTimeout
    ; Timeout tests if they take more than 10 full frames to complete
    .define zest.timeout.default 10
.else
    zest.utils.validate.range zest.defaultTimeout, 1, 255, "zest.defaultTimeout should be between 1 and 255"
    .define zest.timeout.default zest.defaultTimeout
.endif

;====
; RAM state
;====
.ramsection "zest.timeout" slot zest.mapper.RAM_SLOT
    ; The number of remainingFrames the current test has until it times out
    zest.timeout.remainingFrames: db

    ; A checksum of remainingFrames to detect overwrites
    zest.timeout.checksum: db
.ends

;====
; Derive the timeout checksum
;
; @in   a   the remainingFrames value
; @out  a   the checksum
;====
.macro "zest.timeout._calculateChecksum"
    inc a
    rrca
.endm

;====
; Sets the timeout counter to the given value
;
; @in   frames  the number of frames to timeout after
;
; @clobbers af
;====
.macro "zest.timeout._set" args frames
    ; Set timeout (default + 1 frame for the frame we're on)
    ld a, <(frames + 1) ; wrap to 0 for 256 remainingFrames
    ld (zest.timeout.remainingFrames), a

    ; Set checksum
    zest.timeout._calculateChecksum
    ld (zest.timeout.checksum), a
.endm

;====
; Resets the timeout counter to the default value
;
; @clobbers af
;====
.macro "zest.timeout.reset"
    zest.timeout._set zest.timeout.default
.endm

;====
; Sets the timeout for the current test
;
; @in   remainingFrames the number of full frames to time out after
;====
.macro "zest.timeout.setCurrent" args frames
    push af
        zest.timeout._set frames
    pop af
.endm

;====
; Decrements the frame counter for the current test and times out the test with
; a message if the counter reaches zero
;
; Also validates the existing checkum and will jump to the memoryOverwrite
; routine if it is invalid
;
; @clobbers af, hl
;====
.section "zest.timeout.update" free
    zest.timeout.update:
        ; Set L to remainingFrames and H to checksum
        ld hl, (zest.timeout.remainingFrames)

        ; Validate checksum
        ld a, l
        zest.timeout._calculateChecksum
        cp h
        jr nz, _checksumInvalid

        ; Update timeout
        dec l           ; dec remainingFrames
        jr z, _timeout  ; if zero, timeout

        ; Update checksum
        ld a, l                             ; set A to new remainingFrames
        zest.timeout._calculateChecksum     ; calculate checksum
        ld h, a                             ; set H to new checksum

        ; Store values
        ld (zest.timeout.remainingFrames), hl

        ret

    _checksumInvalid:
        jp zest.runner.memoryOverwriteDetected

    _timeout:
        call zest.runner.printTestDescription

        ; Print the failed assertion message
        ld hl, _timeoutMessage
        call zest.runner._printAssertionMessage

        jp zest.console.displayAndStop

    _timeoutMessage:
        zest.console.defineString "Test timed out"
.ends
