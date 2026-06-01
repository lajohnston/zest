;====
; Manages a VBlank callback in RAM that will be jumped to when a VBlank
; interrupt occurs
;====

;====
; RAM
;====
.ramsection "zest.onVBlank.ram" slot zest.mapper.RAM_SLOT
    ; Either a jp to the callback or a ret instruction
    zest.onVBlank.ram.jpToCallbackOrRet:    db

    ; The user specific VBlank callback
    zest.onVBlank.ram.callback:             dw
.ends

;====
; (Private) Sets the given VBlank callback address in RAM
; @in   stack{0}    pointer to the callback address
;====
.section "zest.onVBlank._setCallback" free
    zest.onVBlank._setCallback:
        ex (sp), hl   ; get callback address from stack; preserve hl

        push af
            ld a, $c3   ; jp
            ld (zest.onVBlank.ram.jpToCallbackOrRet), a
            ld a, (hl)
            ld (zest.onVBlank.ram.callback), a
            inc hl
            ld a, (hl)
            ld (zest.onVBlank.ram.callback + 1), a
        pop af

        inc hl  ; point to address after the callback data
        ex (sp), hl   ; restore hl; push return address to stack

        ret
.ends

;====
; Resets any custom VBlank callback so it just returns
;
; @clobbers af
;====
.macro "zest.onVBlank.resetCallback"
    ld a, $c9   ; ret
    ld (zest.onVBlank.ram.jpToCallbackOrRet), a
.endm

;====
; Calls the current custom VBlank callback
;====
.macro "zest.onVBlank.invokeCallback"
    call zest.onVBlank.ram.jpToCallbackOrRet
.endm

;====
; Defines an inline VBlank callback routine that will be jumped over but called
; on the next VBlank.
;
; @in   labelAfterCallback  a label after the callback so it can be jumped over
;                           for now (usually a +)
;====
.macro "zest.onVBlank.defineCallback" args labelAfterCallback
    call zest.onVBlank._setCallback
    .dw zest.onVBlank.customCallback\@  ; define data after the call

    ; jp over the inline callback
    jp labelAfterCallback

    ; Label for the callback following from the macro call
    zest.onVBlank.customCallback\@:
.endm
