INCLUDE "hardware.inc"
INCLUDE "text-macros.inc"

SECTION "Header", ROM0[$100]
	jp EntryPoint
	ds $150 - @, 0

EntryPoint:
WaitVBlank: ; Wait for VBlank -------------------------------------------------
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; Turn the LCD off
    ld a, 0
    ld [rLCDC], a

    ; Copy sprites to VRAM ----------------------------------------------------
    ; Copy letters tiles
    ld de, Letters
    ld hl, $9000
    ld bc, LettersEnd - Letters
    call Memcopy

    ; Copy player tiles
    ld de, Player
    ld hl, $9340
    ld bc, PlayerEnd - Player
    call Memcopy

    ; Clear Object attribute memory (OAM) -------------------------------------
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    ; Initialize the player sprite in OAM -------------------------------------
    ld hl, _OAMRAM
    ld a, 128 + 16
    ld [hli], a
    ld a, 16 + 8
    ld [hli], a
    ld a, 0
    ld [hli], a
    ld [hli], a

    ; Turn the LCD and objects on ---------------------------------------------
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; Initialize display registers
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

; Game loop -------------------------------------------------------------------
Done:
    jp Done

; =============================================================================

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

; Draw a text on screen
; @param de: Start tile
; @param hl: Text address
DrawTextTilesLoop:
    ; Check for the end of string character 255
    ld a, [hl]
    cp 255 ; Keep writing the string until find value 255.
    ret z
    ; Apply offset because letters sprite don't start at VRAM $9000 and write
    ; the current character (in hl) to the address on the tilemap (in de)
    ld a, [hl]
    add a, 39  ; Offset line
    ld [de], a
    inc hl
    inc de
    ; move to the next character and next background tile
    jp DrawTextTilesLoop

; =============================================================================

Letters: INCBIN "letters.2bpp"
LettersEnd:

Player:
    dw `13333331
    dw `30000003
    dw `30000003
    dw `30000003
    dw `30000003
    dw `30000003
    dw `13333331
    dw `00000000
PlayerEnd:
