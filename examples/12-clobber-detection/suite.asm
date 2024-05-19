;====
; Example that tests Zest's register clobber detection
;====

.incdir "../../"
    .include "zest.asm"
.incdir "."

.section "suite" appendto zest.suite
    .include "clobber-detection.test.asm"
.ends
