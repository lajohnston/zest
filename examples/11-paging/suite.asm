; Change the number of suite banks from 1 (the default) to 4
.define zest.SUITE_BANKS 4

; Include the library
.incdir "../../"
    .include "zest.asm"
.incdir "."

;====
; Default bank
;====
zest.setBank 0  ; the default bank, accessible by all tests
.include "src/someCode.asm"

; Append tests to zest.suite
.section "tests in bank 1" appendto zest.suite
    .include "tests/bank1Tests.asm"
.ends

;====
; Second bank
;====

; Place free sections into bank 2, accessible by zest.suiteBank2 tests
zest.setBank 2
.include "src/someMoreCode.asm"

.section "tests in bank 2" appendto zest.suiteBank2
    .include "tests/bank2Tests.asm"
.ends

;====
; Additional banks
;
; Append the tests to zest.suiteBank3, zest.suiteBank4 etc.
;====
.section "tests in bank 3" appendto zest.suiteBank3
    .include "tests/bank3Tests.asm"
.ends

.section "tests in bank 4" appendto zest.suiteBank4
    .include "tests/bank4Tests.asm"
.ends
