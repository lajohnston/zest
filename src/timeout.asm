;====
; Manages a frame counter in RAM
;====

; Default timeout (in full frames) for tests. Should be between 1 and 255
.ifndef zest.defaultTimeout
    ; Timeout tests if they take more than 10 full frames to complete
    .define zest.timeout.default 10
.else
    zest.utils.assert.range zest.defaultTimeout, 1, 255, "zest.defaultTimeout should be between 1 and 255"
    .define zest.timeout.default zest.defaultTimeout
.endif

;====
; RAM state
;====
.ramsection "zest.timeout" slot zest.mapper.RAM_SLOT
    ; The number of remainingFrames the current test has until it times out
    zest.timeout.remainingFrames: db
.ends

;====
; Resets the timeout counter to the default value
;
; @clobs af
;====
.macro "zest.timeout.reset"
    ; Set timeout (default + 1 frame for the frame we're on)
    ld a, <(zest.timeout.default + 1)    ; wrap to 0 for 256 remainingFrames
    ld (zest.timeout.remainingFrames), a
.endm

;====
; Sets the timeout for the current test
;
; @in   remainingFrames the number of full frames to time out after
;====
.macro "zest.timeout.setCurrent" args frames
    push af
        ld a, <(frames + 1) ; frames + current frame (wrap to 0 for 256)
        ld (zest.timeout.remainingFrames), a
    pop af
.endm

;====
; Decrements the frame counter for the current test and times out the test with
; a message if the counter reaches zero
;
; @clobs af
;====
.section "zest.timeout.update" free
    zest.timeout.update:
        ld a, (zest.timeout.remainingFrames)
        dec a
        ld (zest.timeout.remainingFrames), a
        ret nz  ; return if test hasn't timed out yet

        ; Timeout
        push hl
            ld hl, _timeoutMessage
            call zest.runner._printTestFailure
            call zest.console.displayMessage
        pop hl

        ret

    _timeoutMessage:
        .asc "Test timed out"
        .db $ff
.ends
