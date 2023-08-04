;====
; Fails the test if the value in register a does not match the expected value
;
; @in   a           the value to test
; @in   expected    the expected value
;====
.macro "expect.a.toBe" args expected
    cp expected
    call nz, smsspec.runner.expectationFailed
.endm
