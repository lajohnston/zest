; The input bits
.define LEFT_BIT      2
.define RIGHT_BIT     3

.define PORT_1 $dc
.define PORT_2 $dd

.ramsection "Player variables" slot 3
    player1XPosition: db
    player2XPosition: db
.ends

.section "updatePositions" free
    ;===
    ; Read the input value from the controller 1 port ($dc)
    ;===
    updatePlayer1Position:
        readPort PORT_1         ; read the controller 1 input
        ld hl, player1XPosition ; point to player 1 x position
        jp _updatePosition      ; jump to _updatePosition (then returns)

    ;===
    ; Read the input value from the controller 2 ports ($dc and $dd)
    ;===
    updatePlayer2Position:
        call readController2    ; read the controller 2 input
        ld hl, player2XPosition ; point to player 2 x position
        jp _updatePosition      ; jump to _updatePosition (then returns)

    ;====
    ; Update the position based on the input
    ;
    ; @in   a   the input value (--21rldu; 0 = pressed)
    ; @in   hl  pointer to the x position
    ;====
    _updatePosition:
        ; If left pressed, decrement x position
        bit LEFT_BIT, a
        jp nz, +
            dec (hl)
        +

        ; If right pressed, increment x position
        bit RIGHT_BIT, a
        jp nz, +
            inc (hl)
        +

        ret
.ends

;====
; Reads the controller 2 buttons, which are spread amongst PORT_1 and PORT_2
; @out  a   the input values (--21rldu)
;====
.section "readController2" free
    readController2:
        ; Retrieve up and down buttons, which are stored within the PORT_1 byte
        readPort PORT_1
        and %11000000   ; clear port 1 buttons
        ld b, a         ; store in B (DU------)

        ; Read remaining buttons from PORT_2
        readPort PORT_2
        and %00001111   ; reset misc. bits (----21RL)

        ; Combine into 1 byte (DU--21RL)
        or b

        ; Rotate left twice to match port 1 format
        rlca            ; rotate DU--21RL to U--21RLD
        rlca            ; rotate U--21RLD to --21RLDU
        ret
.ends