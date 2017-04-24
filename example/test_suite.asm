; Include smsspec
.include "../dist/smsspec.asm"

; Include the files to test
.include "incrementer.asm"

; Define mocks
.ramsection "mock instances" slot 2
    smsspec.mocks.start: db
    RandomGenerator.generateByte instanceof smsspec.mock
    smsspec.mocks.end: db
.ends

; Define an smsspec.suite label, which smsspec will call
.section "smsspec.suite" free
    smsspec.suite:
        ; Include your test suite files
        .include "incrementer.spec.asm"

        ; End of test suite
        ret
.ends
