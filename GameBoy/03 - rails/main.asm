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
    ; ld de, Letters
    ; ld hl, _VRAM9000
    ; ld bc, LettersEnd - Letters
    ; call Memcopy

    ; Copy background tiles
    ld de, Background
    ld hl, _VRAM9000
    ld bc, BackgroundEnd - Background
    call Memcopy

    ; Copy spaceship tiles
    ld de, Spaceship
    ld hl, _VRAM8000
    ld bc, SpaceshipEnd - Spaceship
    call Memcopy

    ; Copy background tilemap
    ld de, BackgroundTilemap
    ld hl, _SCRN0
    ld bc, BackgroundTilemapEnd - BackgroundTilemap
    call Memcopy

    ; Clear Object attribute memory (OAM) -------------------------------------
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    ; Initialize the player sprite in OAM (4 parts) ---------------------------
    ; Up left
    ld hl, _OAMRAM
    ld a, 40 + 16
    ld [hli], a
    ld a, 16 + 8
    ld [hli], a
    ld a, $0
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Up right
    ld a, 40 + 16
    ld [hli], a
    ld a, 24 + 8
    ld [hli], a
    ld a, $1
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Down left
    ld a, 48 + 16
    ld [hli], a
    ld a, 16 + 8
    ld [hli], a
    ld a, $2
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Down right
    ld a, 48 + 16
    ld [hli], a
    ld a, 24 + 8
    ld [hli], a
    ld a, $3
    ld [hli], a
    ld a, 0
    ld [hli], a

    ; Turn the LCD and objects on ---------------------------------------------
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; Initialize display registers
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ; Initialize global variables ---------------------------------------------
    ld a, 0
    ld [wCurKeys], a
    ld [wNewKeys], a

; Game loop ===================================================================
Main:
    ; Wait until it's *not* VBlank
    ld a, [rLY]
    cp 144
    jp nc, Main
WaitVBlank2:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank2

    call UpdateKeys

; First, check if the left button is pressed
CheckLeft:
    ld a, [wCurKeys]
    and a, PADF_LEFT
    jp z, CheckRight
Left:
    ; Move the player one pixel to the left
    ld a, [_OAMRAM + 1]
    dec a
    ld [_OAMRAM + 1], a
    ld a, [_OAMRAM + 5]
    dec a
    ld [_OAMRAM + 5], a
    ld a, [_OAMRAM + 9]
    dec a
    ld [_OAMRAM + 9], a
    ld a, [_OAMRAM + 13]
    dec a
    ld [_OAMRAM + 13], a
    jp Main

; Now check the if the right button is pressed
CheckRight:
    ld a, [wCurKeys]
    and a, PADF_RIGHT
    jp z, Main
Right:
    ; Move the player one pixel to the right
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM + 1], a
    ld a, [_OAMRAM + 5]
    inc a
    ld [_OAMRAM + 5], a
    ld a, [_OAMRAM + 9]
    inc a
    ld [_OAMRAM + 9], a
    ld a, [_OAMRAM + 13]
    inc a
    ld [_OAMRAM + 13], a
    jp Main

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

; Read player input
UpdateKeys:
    ; Poll half the controller (buttons A, B, start, select)
    ld a, P1F_GET_BTN
    call .onenibble
    ld b, a     ; B7-4 = 1; B3-0 = unpressed buttons

    ; Poll the other half (directions buttons)
    ld a, P1F_GET_DPAD
    call .onenibble
    swap a      ; A3-0 = unpressed directions; A7-4 = 1
    xor a, b    ; A = pressed buttons + directions
    ld b, a     ; B = pressed buttons + directions

    ; And release the controller
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ; Combine with previous wCurrKeys to make wNewKeys
    ld a, [wCurKeys]
    xor a, b    ; A = keys that changed state
    and a, b    ; A = keys that changed to pressed
    ld [wNewKeys], a
    ld a, b
    ld [wCurKeys], a
    ret

.onenibble
    ldh [rP1], a    ; Switch the key matrix
    call .knownret  ; Burn 10 cycles calling a known ret
    ldh a, [rP1]    ; Ignore value while waiting for the key matrix to settle
    ldh a, [rP1]
    ldh a, [rP1]    ; This read counts
    or a, $F0       ; A7-4 = 1; A3-0 = unpressed keys

.knownret
    ret

; =============================================================================
SECTION "Sprites", ROM0

Letters: INCBIN "text-font.2bpp"
LettersEnd:

Spaceship: INCBIN "spaceship.2bpp"
SpaceshipEnd:

Background: INCBIN "background.2bpp"
BackgroundEnd:

BackgroundTilemap: INCBIN "background.tilemap"
BackgroundTilemapEnd:

; Work RAM, we can create variables here --------------------------------------
SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db
