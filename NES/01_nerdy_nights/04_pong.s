; Pong game ===================================================================
.segment "HEADER"
	.byte $4E, $45, $53, $1A  	; iNES header identifier
	.byte $02					; 2x 16KB PRG code
	.byte $01					; 1x  8KB CHR data
	.byte $01, $00				; mapper 0 = NROM, no bank swapping / background mirroring

; =============================================================================
.segment "VECTORS"
	.addr nmi
	.addr reset
	.addr 0

; =============================================================================
.segment "STARTUP"
; nes linker config requires a STARTUP section, even if its empty

; =============================================================================
.segment "ZEROPAGE" ; Quick access variables (addresses: $00–$FF)
gamestate: 		.res 1
ballx: 			.res 1
bally: 			.res 1
ballup: 		.res 1
balldown:		.res 1
ballleft:		.res 1
ballright:		.res 1
ballspeedx:		.res 1
ballspeedy:		.res 1
paddle1ytop:	.res 1
paddle2ybot:	.res 1
buttons1:		.res 1
buttons2:		.res 1
score1:			.res 1
score2:			.res 1
pointerLo: 		.res 1 	; used in background load loop
pointerHi: 		.res 1	; used in background load loop

STATE_TILE 		= $00
STATE_PLAYING 	= $01
STATE_GAMEOVER  = $02
RIGHT_WALL 		= $E1
TOP_WALL 		= $1E
BOTTOM_WALL 	= $C8
LEFT_WALL 		= $17
PADDLE1X		= $18
PADDLE2X 		= $E0
PADDLE_SPEED 	= $02

; =============================================================================
.segment "CODE"

vBlankWait:
	bit $2002
	bpl vBlankWait
	rts

reset:
	sei				; disable IRQs
	cld				; disable decimal mode
	ldx #$40
	stx $4017		; disable APU frame IRQ
	ldx #$ff 		; Set up stack
	txs
	inx				; now X = 0
	stx $2000		; disable NMI
	stx $2001 		; disable rendering
	stx $4010 		; disable DMC IRQs

	jsr vBlankWait 	; vBlank wait #1

clearMemory:
	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	LDA #$FE
	STA $0300, x
	inx
	bne clearMemory

	jsr vBlankWait 	; vBlank wait #2

; Setup color palettes --------------------------------------------------------
	lda $2002
	lda #$3f 		; high byte
	sta $2006		; write on port
	lda #$10		; low byte
	sta $2006		; write on port
	ldx #$00
LoadPalettesLoop:
	lda paletteData, x
	sta $2007
	inx
	cpx #$20 		; decimal: 16
	bne LoadPalettesLoop

; Load background -------------------------------------------------------------
LoadBackground:
	lda $2002 				; read PPU status to reset the latch
	lda #$20
	sta $2006 				; write the high byte of $2000 address
	lda #$00
	sta $2006 				; write the low byte of $2000 address

	lda #(<backgroundData)
	sta pointerLo				; put the low byte of the address of background into pointer
	lda #(>backgroundData)		; get the high byte of the address
	sta pointerHi				; put the high byte of the address into pointer

	ldx #$00					; start at pointer + 0
	ldy #$00					; start at pointer + 0
OutsideBackgroundLoop:
InsideBackgroundLoop:
	lda (pointerLo), y
	sta $2007
	iny							; inside loop counter
	cpy #$00
	bne InsideBackgroundLoop	; run the inside loop 256 times before continuing down
	inc pointerHi				; low byte went 0 to 256, so high byte needs to be changed now
	inx
	cpx #$04
	bne OutsideBackgroundLoop	; run the outside loop 256 times before continuing down

; Load background attributes --------------------------------------------------
LoadAttribute:
	lda $2002 			; read PPU status to reset the latch
	lda #$23
	sta $2006			; write the high byte of $23c0 address
	lda #$c0
	sta $2006			; write the low byte of $23c0 address

	ldx #$00			; start loop index
LoadAttributeLoop:
	lda attributeData, x
	sta $2007
	inx
	cpx #$40 			; decimal: 64
	bne LoadAttributeLoop

; Set initial ball stats --------------
	lda #$01
	sta balldown
	sta ballright
	lda #$00
	sta ballup
	sta ballleft

	lda #$50
	sta bally

	lda #$80
	sta ballx

	lda #$02
	sta ballspeedx
	sta ballspeedy

; Set initial paddle positions --------
	lda #$70
	sta paddle1ytop
	sta paddle2ybot

; Set starting game state -------------
	lda #STATE_PLAYING
	sta gamestate

; Enable NMI and PPU ----------------------------------------------------------
finalSettings:
	lda #%10011000 	; Enable NMI and background
	sta $2000
	lda #%00011000 	; Setup PPU port: bit 5: enable sprites / bit 4: enable bg
	sta $2001
	lda #%00000001 	; Setup API: enable square 1
	sta $4015

forever:
	jmp forever

; =============================================================================
nmi:
	; DMA transfer
	lda #$02
	sta $4014

	jsr drawScore

	lda #$00 	; set no background scrolling
	sta $2005
	sta $2005

; All graphics updates done by here, run game engine --------------------------
	jsr readController1
	jsr readController2

gameEngine:
	lda gamestate
	cmp #STATE_TILE
	beq engineTitle

	lda gamestate
	cmp #STATE_GAMEOVER
	beq engineGameOver
	
	lda gamestate
	cmp #STATE_PLAYING
	beq enginePlaying
gameEngineDone:

	jsr updateSprites

	rti

; Subroutines -----------------------------------------------------------------
engineTitle:
	; TODO
	jmp gameEngineDone

engineGameOver:
	; TODO
	jmp gameEngineDone

enginePlaying:

moveBallRight:
	lda ballright
	beq moveBallRightDone

	lda ballx
	clc
	adc ballspeedx 			; ballx position = ballx + ballspeedx
	sta ballx

	lda ballx
	cmp #RIGHT_WALL
	bcc moveBallRightDone 	; if ball x < right wall, skip next section
	lda #$00
	sta ballright
	lda #$01
	sta ballleft
moveBallRightDone:

moveBallLeft:
	lda ballleft
	beq moveBallLeftDone

	lda ballx
	sec
	sbc ballspeedx
	sta ballx

	lda ballx
	cmp #LEFT_WALL
	bcs moveBallLeftDone
	lda #$01
	sta ballright
	lda #$00
	sta ballleft
moveBallLeftDone:

moveBallUp:
	lda ballup
	beq moveBallUpDone 		; if ballup=0, skip

	lda bally
	sec
	sbc ballspeedy
	sta bally

	lda bally
	cmp #TOP_WALL
	bcs moveBallUpDone
	lda #$01
	sta balldown
	lda #$00
	sta ballup
moveBallUpDone:

moveBallDown:
	lda balldown
	beq moveBallDownDone

	lda bally
	clc
	adc ballspeedy
	sta bally

	lda bally
	cmp #BOTTOM_WALL
	bcc moveBallDownDone
	lda #$00
	sta balldown
	lda #$01
	sta ballup
moveBallDownDone:

movePaddleUp:
	lda buttons1
	and #%00001000
	beq movePaddleUpDone
	; Buttom pressed!
	lda paddle1ytop
	cmp #TOP_WALL 			; check top limit
	beq movePaddleUpDone
	sec
	sbc #PADDLE_SPEED
	sta paddle1ytop
movePaddleUpDone:

movePaddleDown:
	lda buttons1
	and #%00000100
	beq movePaddleDownDone
	; Buttom pressed!
	lda paddle1ytop
	cmp #BOTTOM_WALL - $18
	beq movePaddleDownDone
	clc
	adc #PADDLE_SPEED
	sta paddle1ytop
movePaddleDownDone:

moveOponentPaddle:
	lda bally
	sec
	sbc #$08 			; aim the center
	sta paddle2ybot

checkPaddle1Collision:
	; check X position
	lda ballx
	sec
	cmp #PADDLE1X + $08 			; consider paddle size
	bcs checkPaddle1CollisionDone

	; check ball above paddle
	lda bally
	clc
	cmp paddle1ytop
	bcc checkPaddle1CollisionDone

	; check ball bellow paddle
	sec
	lda bally
	sbc paddle1ytop
	cmp #$20						; consider paddle heigth (4 sprites)
	bcs checkPaddle1CollisionDone

	; bounce ball, if code reach here
	lda #$01
	sta ballright
	lda #$00
	sta ballleft
	; Play sound
	lda #%01001111
	sta $4000
	lda #$C9
	sta $4002
	lda #%00010001
	sta $4003
checkPaddle1CollisionDone:

checkPaddle2Collision:
	; check X position
	lda ballx
	clc
	cmp #PADDLE2X - $08 			; consider ball size
	bcc checkPaddle2CollisionDone

	; Paddle 2 Y position check missing here! ######
	; Since the AI will always get the ball.  ######

	; bounce ball, if code reach here
	lda #$01
	sta ballleft
	lda #$00
	sta ballright
	; Play sound
	lda #%01001111
	sta $4000
	lda #$C9
	sta $4002
	lda #%00010011
	sta $4003
checkPaddle2CollisionDone:

	jmp gameEngineDone

updateSprites:
	; ball ------------------
	lda bally	; y pos
	sta $0200
	lda #$00	; tile number
	sta $0201
	lda #$00	; attrs
	sta $0202
	lda ballx 	; x pos
	sta $0203

	; right paddle ----------
	lda paddle1ytop 	; tile 1
	sta $0204
	lda #$49
	sta $0205
	lda #$00
	sta $0206
	lda #PADDLE1X
	sta $0207

	lda paddle1ytop		 ; tile 2
	clc
	adc #$08
	sta $0208
	lda #$4A
	sta $0209
	lda #$00
	sta $020A
	lda #PADDLE1X
	sta $020B

	lda paddle1ytop		 ; tile 3
	clc
	adc #$0F
	sta $020C
	lda #$4A
	sta $020D
	lda #$00
	sta $020E
	lda #PADDLE1X
	sta $020F

	lda paddle1ytop		 ; tile 4
	clc
	adc #$17
	sta $0210
	lda #$7A
	sta $0211
	lda #$00
	sta $0212
	lda #PADDLE1X
	sta $0213

	; left paddle -----------
	lda paddle2ybot		; tile 1
	sta $0214
	lda #$44
	sta $0215
	lda #$00
	sta $0216
	lda #PADDLE2X
	sta $0217

	lda paddle2ybot		; tile 2
	clc
	adc #$08
	sta $0218
	lda #$46
	sta $0219
	lda #$00
	sta $021A
	lda #PADDLE2X
	sta $021B

	lda paddle2ybot		; tile 3
	clc
	adc #$0F
	sta $021C
	lda #$46
	sta $021D
	lda #$00
	sta $021E
	lda #PADDLE2X
	sta $021F

	lda paddle2ybot		; tile 4
	clc
	adc #$17
	sta $0220
	lda #$5F
	sta $0221
	lda #$00
	sta $0222
	lda #PADDLE2X
	sta $0223

	rts

drawScore:
	; TODO
	rts

readController1:
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    ldx #$08
readController1Loop:
    lda $4016
    lsr A
    rol buttons1
	dex
    bne readController1Loop
    rts

readController2:
	lda #$01
	sta $4016
	lda #$00
	sta $4016
	ldx #$08
readController2Loop:
	lda $4017
	lsr A
	rol buttons2
	dex
	bne readController2Loop
	rts

; =============================================================================
.segment "RODATA"
paletteData:
	.byte $22,$16,$36,$0F,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C ; sprite palette
	.byte $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F ; background palette

backgroundData:
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.byte $24,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$24
	.byte $24,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24
	.byte $24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24
	.byte $24,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$53,$54,$24
	.byte $24,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$55,$56,$24
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24

attributeData:
	.byte %11111111, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
	.byte %11111111, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11111111
	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111

; =============================================================================
.segment "CHARS"
	.org $0000
	.incbin "mario.chr"
