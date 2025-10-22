INCLUDE "hardware.inc"

DEF ATTACK_SPRITE_X_OFFSET          EQU 9
DEF ATTACK_SPRITE_ATTR_OFFSET       EQU 11
DEF PLAYER_SPRITE_HEAD_X_OFFSET     EQU 1
DEF PLAYER_SPRITE_LEGS_X_OFFSET     EQU 5
DEF PLAYER_SPRITE_HEAD_ATTR_OFFSET  EQU 3
DEF PLAYER_SPRITE_LEGS_ATTR_OFFSET  EQU 7

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

; Initialize player sprites in OAM --------------------------------------------
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

    ld a, 126 + 16  ; Set object Y position
    ld [hli], a
    ld a, 0         ; Set object X position (out of screen)
    ld [hli], a
    ld a, 4         ; Set object index
    ld [hli], a
    ld a, 0         ; Set attributes
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
    ld [wAttackTimer], a
    ld [wPlayerIsAttacking], a
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
    call UpdatePlayerFlip
    call UpdateAttack

; Check if the attack buttom is just pressed
CheckAttack:
    ld a, [wNewKeys]
    and a, PADF_B
    jp z, CheckLeft
StartAttack:
    ld a, 8                 ; Attack for 8 frames
    ld [wAttackTimer], a
    call SpawnAttack

; Check if the left buttom is pressed
CheckLeft:
    ld a, [wCurKeys]
    and a, PADF_LEFT
    jp z, CheckRight
MovePlayerToLeft:
    ; Change direction
    ld a, 0
    ld [wPlayerDirection], a
	; Move head
    ld a, [_OAMRAM + PLAYER_SPRITE_HEAD_X_OFFSET]
    dec a
    ld [_OAMRAM + PLAYER_SPRITE_HEAD_X_OFFSET], a
    ; Move legs
    ld a, [_OAMRAM + PLAYER_SPRITE_LEGS_X_OFFSET]
    dec a
    ld [_OAMRAM + PLAYER_SPRITE_LEGS_X_OFFSET], a
    ; Alternate legs frames
	call AnimateLegs
    ld a, [wAnimationFrame]
    ld [_OAMRAM + 6], a
    jp Main

; Check the if the right buttom is pressed
CheckRight:
    ld a, [wCurKeys]
    and a, PADF_RIGHT
    jp z, EndCheck
MovePlayerToRight:
    ; Change direction
    ld a, 1
    ld [wPlayerDirection], a
	; Move head
    ld a, [_OAMRAM + PLAYER_SPRITE_HEAD_X_OFFSET]
    inc a
    ld [_OAMRAM + PLAYER_SPRITE_HEAD_X_OFFSET], a
    ; Move legs
    ld a, [_OAMRAM + PLAYER_SPRITE_LEGS_X_OFFSET]
    inc a
    ld [_OAMRAM + PLAYER_SPRITE_LEGS_X_OFFSET], a
    ; Alternate legs frames
	call AnimateLegs
    ld a, [wAnimationFrame]
    ld [_OAMRAM + 6], a
    jp Main

EndCheck:

; If no keys pressed, load the idle legs
LoadIdleLegs:
	ld a, 1
	ld [_OAMRAM + 6], a
	jp Main

; End of main loop ------------------------------------------------------------
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

; Update player flip ----------------------------------------------------------
UpdatePlayerFlip:
    ld a, [wPlayerDirection]
    cp 0
    jr nz, .FacingRight
.FacingLeft:
    ld hl, _OAMRAM + PLAYER_SPRITE_HEAD_ATTR_OFFSET
    ld a, [hl]
    or %00100000
    ld [hl], a
    ld hl, _OAMRAM + PLAYER_SPRITE_LEGS_ATTR_OFFSET
    ld a, [hl]
    or %00100000
    ld [hl], a
    ret
.FacingRight:
    ld hl, _OAMRAM + PLAYER_SPRITE_HEAD_ATTR_OFFSET
    ld a, [hl]
    and %11011111
    ld [hl], a
    ld hl, _OAMRAM + PLAYER_SPRITE_LEGS_ATTR_OFFSET
    ld a, [hl]
    and %11011111
    ld [hl], a
    ret

; Increment frame counter -----------------------------------------------------
IncrementFrameCounter:
    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    ret

; Spawn attack ----------------------------------------------------------------
SpawnAttack:
    ; Took body X and Y position as reference
    ld a, [_OAMRAM + 4]
    sub 2
    ld c, a
    ld a, [_OAMRAM + 5]
    ld b, a

    ; Calculate direction
    ld a, [wPlayerDirection]
    or a
    jr nz, .AttackFacingRight

.AttackFacinfLeft:
    ld a, b
    sub 8           ; Attack 8px to left
    ld d, a
    jr .Spawn

.AttackFacingRight:
    ld a, b
    add 8           ; Attack 8px to right
    ld d, a

.Spawn:
    ld hl, _OAMRAM + 8
    ld a, c
    ld [hli], a     ; Y
    ld a, d
    ld [hli], a     ; X

    ld a, [wPlayerDirection]
    or a
    jr nz, .NoFlip

.FlipAttackLeft:
    ld a, [_OAMRAM + ATTACK_SPRITE_ATTR_OFFSET]
    or %00100000
    ld [_OAMRAM + ATTACK_SPRITE_ATTR_OFFSET], a
    ret

.NoFlip:
    ld a, [_OAMRAM + ATTACK_SPRITE_ATTR_OFFSET]
    and %11011111
    ld [_OAMRAM + ATTACK_SPRITE_ATTR_OFFSET], a
    ret

; Update attack animation -----------------------------------------------------
UpdateAttack:
    ; Check if the attack animation is over
    ld a, [wAttackTimer]
    or a
    ret z               ; Do nothing if 0

    dec a
    ld [wAttackTimer], a
    jp nz, .StillActive

    ; Attack finished, remove sprite
    ld hl, _OAMRAM + 8
    ld a, 0
    ld [hli], a         ; Y
    ld [hli], a         ; X
    ret

.StillActive:
    ; Move attack sprite depending on direction
    ld a, [wPlayerDirection]
    or a
    jr nz, .MoveAttackRight
.MoveAttackLeft:
    ld a, [_OAMRAM + ATTACK_SPRITE_X_OFFSET]
    dec a
    ld [_OAMRAM + ATTACK_SPRITE_X_OFFSET], a
    ret
.MoveAttackRight:
    ld a, [_OAMRAM + ATTACK_SPRITE_X_OFFSET]
    inc a
    ld [_OAMRAM + ATTACK_SPRITE_X_OFFSET], a
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
wPlayerIsAttacking: db  ; 0: not attacking, 1: attacking
wAttackTimer: db
