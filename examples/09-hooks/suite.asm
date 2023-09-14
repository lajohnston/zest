; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Hooks
.ramsection "hooks" slot zest.RAM_SLOT
    preTestCounter:     db
    postTestCounter:    db
.ends

.define startingValue 100

; Runs once at start of suite
.section "myPreSuiteHook" appendto zest.preSuite keep
    ; Set counters to startingValue
    ld a, startingValue
    ld (preTestCounter), a
    ld (postTestCounter), a
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
    .include "hooks.test.asm"
.ends
