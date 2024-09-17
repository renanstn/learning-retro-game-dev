INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
	jp EntryPoint
	ds $150 - @, 0

EntryPoint:
; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

    ; Copy letters tiles
    ld de, letters
    ld hl, $9270
    ld bc, lettersEnd - letters
    call Memcopy

    ; Copy berg tile data
    ld de, bergTileData
    ld hl, $9000
    ld bc, bergTileDataEnd - bergTileData
    call Memcopy

    ; Copy tile map
    ld de, bergTileMap
    ld hl, $9800
    ld bc, bergTileMapEnd - bergTileMap
    call Memcopy

    ; Write text
    ld a, $4D       ; M
    ld hl, $9887
    ld [hl], a
    ld a, $45       ; E
    ld hl, $9888
    ld [hl], a
    ld a, $27       ; Space
    ld hl, $9889
    ld [hl], a
    ld a, $56       ; V
    ld hl, $988A
    ld [hl], a
    ld a, $45       ; E
    ld hl, $988B
    ld [hl], a
    ld a, $27       ; Space
    ld hl, $988C
    ld [hl], a
    ld a, $44       ; D
    ld hl, $988D
    ld [hl], a
    ld a, $4F       ; O
    ld hl, $988E
    ld [hl], a
    ld a, $49       ; I
    ld hl, $988F
    ld [hl], a
    ld a, $53       ; S
    ld hl, $9890
    ld [hl], a
    ld a, $44       ; D
    ld hl, $98A7
    ld [hl], a
    ld a, $45       ; E
    ld hl, $98A8
    ld [hl], a
    ld a, $52       ; R
    ld hl, $98A9
    ld [hl], a
    ld a, $42       ; B
    ld hl, $98AA
    ld [hl], a
    ld a, $59       ; Y
    ld hl, $98AB
    ld [hl], a
    ld a, $27       ; Space
    ld hl, $98AC
    ld [hl], a
    ld a, $53       ; S
    ld hl, $98AD
    ld [hl], a
    ld a, $4F       ; O
    ld hl, $98AE
    ld [hl], a
    ld a, $4C       ; L
    ld hl, $98AF
    ld [hl], a
    ld a, $54       ; T
    ld hl, $98B0
    ld [hl], a
    ld a, $4F       ; O
    ld hl, $98B1
    ld [hl], a

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a

Done:
    jp Done

; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcopy
    ret

letters: INCBIN "letters.2bpp"
lettersEnd:

bergTileData: INCBIN "berg.2bpp"
bergTileDataEnd:

bergTileMap: INCBIN "berg.tilemap"
bergTileMapEnd:
