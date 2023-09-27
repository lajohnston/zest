; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Hooks
.ramsection "hooks" slot zest.RAM_SLOT
    preSuiteCounter:    db

    preTestCounter:     db
    postTestCounter:    db

    testValue:          db
.ends

.section "resetCounters"
    resetCounters:
        ld a, 0
        ld (preSuiteCounter), a
        ld (preTestCounter), a
        ld (postTestCounter), a

        ret
.ends

; Runs once at start of suite
.section "myPreSuiteHook" appendto zest.preSuite
    call resetCounters

    ld hl, preSuiteCounter
    inc (hl)
.ends

; Runs before each test
.section "myPreTestHook" appendto zest.preTest
    ; Increment preTestCounter
    ld hl, preTestCounter
    inc (hl)
.ends

; Runs after each test
.section "myPostTestHook" appendto zest.postTest
    ; Increment postTestCounter
    ld hl, postTestCounter
    inc (hl)
.ends

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "preSuite.test.asm"
    .include "preTest.test.asm"
    .include "postTest.test.asm"
.ends
