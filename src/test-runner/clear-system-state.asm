.section "smsspec.clearSystemState" free
    smsspec.clearSystemState:
        ; Clear mocks to defaults
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / 3 ; number of mocks

        _clearMocks:
            ld hl, smsspec.mocks.start

            -:  ; Each mock
                inc hl

                ; Clear times called
                ld (hl), 0

                ; Reset mock handler to the default
                inc hl
                ld (hl), < smsspec.mock.default_handler
                inc hl
                ld (hl), > smsspec.mock.default_handler
            djnz -

        ; Clear registers
        xor a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a
        ld ix, 0
        ld iy, 0

        ; do same for shadow flags

        ; reset fps counter
        ret
.ends
