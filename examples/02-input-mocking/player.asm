; The input bits
.define LEFT_BIT      2
.define RIGHT_BIT     3

.ramsection "Player variables" slot 3
    playerXPos: dw
.ends

.section "Update the player's position" free
    updatePosition:
        ; Read the input value from the controller
        readPlayer1Input    ; (we've stubbed this out in our test)

        ; If right pressed, increment x position
        bit RIGHT_BIT, a
        jp nz, +
            ld hl, playerXPos   ; point to X position
            inc (hl)
        +

        ; If left pressed, decrement x position
        bit LEFT_BIT, a
        jp nz, +
            ld hl, playerXPos   ; point to X position
            dec (hl)
        +

        ret
.ends
