;====
; Main suite
;====

;====
; Run each of the test suites
;====
.macro "zest.suites.run"
    call zest.preSuite

    ; Run tests in first suite bank
    zest.mapper.pageBank 1
    call zest.suite

    ; Runs tests in additional suite banks
    .repeat zest.mapper.SUITE_BANKS - 1 index index
        zest.mapper.pageBank index + 2
        call zest.suiteBank{index + 2}
    .endr
.endm

;====
; Bank 1 (default)
;====
.section "zest.suite" free bank 1 slot zest.mapper.SUITE_SLOT keep
    zest.suite:
        ; Tests get appended here
        ; zest.suite.footer finishes the code block
.ends

.section "zest.suite.footer" appendto zest.suite priority zest.FOOTER_PRIORITY
    ret
.ends

;====
; Additional suite banks
;====
.if zest.mapper.SUITE_BANKS > 1
    .repeat zest.mapper.SUITE_BANKS - 1 index index
        .redefine suites._bank index + 2    ; start from bank 2
        .redefine suites._label {"zest.suiteBank{suites._bank}"}

        .section "{suites._label}" free bank suites._bank slot zest.mapper.SUITE_SLOT keep
            {suites._label}:
                ; Tests get appended here
                ; {suites._label}.footer finishes the code block
        .ends

        .section "{suites._label}.footer" appendto {suites._label} priority zest.FOOTER_PRIORITY
            ret
        .ends
    .endr
.endif