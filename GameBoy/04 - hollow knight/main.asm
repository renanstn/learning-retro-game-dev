INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
	jp EntryPoint
	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off --------------------------------------------------------
	ld a, 0
	ld [rLCDC], a

	; Copy tiles data ---------------------------------------------------------
	ld de, Tiles
	ld hl, $8000
	ld bc, TilesEnd - Tiles
	call Memcopy

    ; Clear OAM ---------------------------------------------------------------
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

; Initialize the player sprite in OAM -----------------------------------------
    ld hl, _OAMRAM  ; Point to address
    ld a, 120 + 16  ; Set object Y position
    ld [hli], a
    ld a, 16 + 8    ; Set object X position
    ld [hli], a
    ld a, 0         ; Set object index
    ld [hli], a
    ld a, 0         ; Set attributes
    ld [hli], a

    ld a, 128 + 16  ; Set object Y position
    ld [hli], a
    ld a, 16 + 8    ; Set object X position
    ld [hli], a
    ld a, 1         ; Set object index
    ld [hli], a
    ld a, 0 		; Set attributes
    ld [hli], a

	; Turn the LCD and objects on ---------------------------------------------
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (black) frame, initialize display registers ------------
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ; Init variables ----------------------------------------------------------
    ld a, 0
    ld [wFrameCounter], a
    ld [wCurKeys], a
    ld [wNewKeys], a
    ld a, 1
    ld [wPlayerDirection], a

; =============================================================================
Main:
    ; Wait until it's not VBlank
    ld a, [rLY]
    cp 144
    jp nc, Main
WaitVBlank2:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank2

    call IncrementFrameCounter
    call UpdateKeys

; Check if the left button is pressed
CheckLeft:
    ld a, [wCurKeys]
    and a, PADF_LEFT
    jp z, CheckRight
MovePlayerToLeft:
    ; Change direction
    ld a, 0
    ld [wPlayerDirection], a
	; Move head
    ld a, [_OAMRAM + 1]
    dec a
    ld [_OAMRAM + 1], a
    ; Move legs
    ld a, [_OAMRAM + 5]
    dec a
    ld [_OAMRAM + 5], a
    ; Alternate legs frames
	call AnimateLegs
    ld a, [wAnimationFrame]
    ld [_OAMRAM + 6], a
    jp Main

; Check the if the right button is pressed
CheckRight:
    ld a, [wCurKeys]
    and a, PADF_RIGHT
    jp z, EndCheck
MovePlayerToRight:
    ; Change direction
    ld a, 1
    ld [wPlayerDirection], a
	; Move head
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM + 1], a
    ; Move legs
    ld a, [_OAMRAM + 5]
    inc a
    ld [_OAMRAM + 5], a
    ; Alternate legs frames
	call AnimateLegs
    ld a, [wAnimationFrame]
    ld [_OAMRAM + 6], a
    jp Main

EndCheck:

; If no keys pressed, load the idle legs
	ld a, 1
	ld [_OAMRAM + 6], a
	jp Main

    ; End of main loop --------------------------------------------------------
    jp Main

; -----------------------------------------------------------------------------
; Copy bytes from one area to another.
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

; Animate legs ----------------------------------------------------------------
AnimateLegs:
	ld a, [wFrameCounter]
	and %00001000 			; change each 8 frames
	jr z, .frame0
.frame1:
	ld a, 2
	jr .set
.frame0:
	ld a, 3
.set:
	ld [wAnimationFrame], a
	ret


; Increment frame counter -----------------------------------------------------
IncrementFrameCounter:
    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    ret

; Read player input -----------------------------------------------------------
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

Tiles:
	INCBIN "test.2bpp"
TilesEnd:

Tilemap:
TilemapEnd:

; =============================================================================
SECTION "Vars", WRAM0
wCurKeys: db
wNewKeys: db
wFrameCounter: db
wAnimationFrame: db
wPlayerDirection: db    ; 0: left, 1: right
