.orga $0038
.section "Interrupt handler" force
    push af
        in a, (smsspec.ports.vdp.status) ; satisfy interrupt
        call smsspec.onVBlank
    pop af
    ei
    reti
.ends

.section "smsspec.onVBlank" free
    smsspec.onVBlank:
        ret
.ends
