.section "smsspec.clearSystemState" free
    smsspec.clearSystemState:
        ; Clear mocks to defaults
        ld hl, smsspec.mocks.start + 1
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / _sizeof_smsspec.mock ; number of mocks
        call smsspec.mock.initAll

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
