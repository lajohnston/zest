.section "Incrementer" free
    Incrementer.increment:
        inc a
        ret

    Incrementer.incrementRandom:
        push bc
            ld b, a
            call RandomGenerator.generateByte
            add a, b
        pop bc

        ret
.ends
