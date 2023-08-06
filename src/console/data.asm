.section "smsspec.console.data" free
    .asciitable
        map " " to "~" = 0
    .enda

    smsspec.console.data.heading:
        .asc "SMSSpec"
        .db $ff ; terminator byte

    smsspec.console.data.allTestsPassed:
        .asc "All tests passed!"
        .db $ff ; terminator byte

    smsspec.console.data.palette:
        .db $00,$0C,$03 ; Black, green, red
    smsspec.console.data.paletteEnd:

    ; Console font
    smsspec.console.data.font:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $6C,$00,$00,$00,$6C,$00,$00,$00,$6C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $36,$00,$00,$00,$36,$00,$00,$00,$7F,$00,$00,$00,$36,$00,$00,$00
    .db $7F,$00,$00,$00,$36,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$3F,$00,$00,$00,$68,$00,$00,$00,$3E,$00,$00,$00
    .db $0B,$00,$00,$00,$7E,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$00,$00,$00,$00
    .db $38,$00,$00,$00,$6C,$00,$00,$00,$6C,$00,$00,$00,$38,$00,$00,$00
    .db $6D,$00,$00,$00,$66,$00,$00,$00,$3B,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$3C,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$6E,$00,$00,$00,$7E,$00,$00,$00
    .db $76,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00
    .db $18,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$1C,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$1C,$00,$00,$00,$3C,$00,$00,$00,$6C,$00,$00,$00
    .db $7E,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$06,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $1C,$00,$00,$00,$30,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00
    .db $06,$00,$00,$00,$0C,$00,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$60,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$06,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$6E,$00,$00,$00,$6A,$00,$00,$00
    .db $6E,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$6C,$00,$00,$00,$78,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$6E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3E,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00
    .db $0C,$00,$00,$00,$6C,$00,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$6C,$00,$00,$00,$78,$00,$00,$00,$70,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $63,$00,$00,$00,$77,$00,$00,$00,$7F,$00,$00,$00,$6B,$00,$00,$00
    .db $6B,$00,$00,$00,$63,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$76,$00,$00,$00,$7E,$00,$00,$00
    .db $6E,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $6A,$00,$00,$00,$6C,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $6C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $63,$00,$00,$00,$63,$00,$00,$00,$6B,$00,$00,$00,$6B,$00,$00,$00
    .db $7F,$00,$00,$00,$77,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$60,$00,$00,$00,$30,$00,$00,$00,$18,$00,$00,$00
    .db $0C,$00,$00,$00,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $3E,$00,$00,$00,$06,$00,$00,$00,$06,$00,$00,$00,$06,$00,$00,$00
    .db $06,$00,$00,$00,$06,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00,$42,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00
    .db $1C,$00,$00,$00,$36,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$06,$00,$00,$00
    .db $3E,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $06,$00,$00,$00,$06,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $1C,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$3C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$70,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$66,$00,$00,$00,$6C,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $38,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$36,$00,$00,$00,$7F,$00,$00,$00
    .db $6B,$00,$00,$00,$6B,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$7C,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$07,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$6C,$00,$00,$00,$76,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$60,$00,$00,$00
    .db $3C,$00,$00,$00,$06,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00,$30,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$1C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$63,$00,$00,$00,$6B,$00,$00,$00
    .db $6B,$00,$00,$00,$7F,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $18,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$3C,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00,$0C,$00,$00,$00
    .db $18,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$70,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$0E,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $31,$00,$00,$00,$6B,$00,$00,$00,$46,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    smsspec.console.data.font_end:
.ends
