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

    ; Copy tile data
    ld de, bergTileData
    ld hl, $9000
    ld bc, bergTileDataEnd - bergTileData
    call Memcopy

    ; Copy tile map
    ld de, bergTileMap
    ld hl, $9800
    ld bc, bergTileMapEnd - bergTileMap
    call Memcopy

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

bergTileData: INCBIN "berg.2bpp"
bergTileDataEnd:

bergTileMap: INCBIN "berg.tilemap"
bergTileMapEnd:
