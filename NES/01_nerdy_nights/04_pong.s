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

STATE_TILE 		= $00
STATE_PLAYING 	= $01
STATE_GAMEOVER  = $02
RIGHT_WALL 		= $F4
TOP_WALL 		= $20
BOTTOM_WALL 	= $D0
LEFT_WALL 		= $04
PADDLE1X		= $08
PADDLE2X 		= $F0
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

; Set initial ball stats --------------
	lda #$01
	sta balldown
	sta ballleft
	lda #$00
	sta ballup
	sta ballright

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
	lda #%00010000 	; Setup PPU port: bit 5: enable sprites / bit 4: enable bg
	sta $2001

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
	lda paddle1ytop
	sec
	sbc #PADDLE_SPEED
	sta paddle1ytop
movePaddleUpDone:

movePaddleDown:
	lda buttons1
	and #%00000100
	beq movePaddleDownDone
	lda paddle1ytop
	clc
	adc #PADDLE_SPEED
	sta paddle1ytop
movePaddleDownDone:

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
checkPaddle1CollisionDone:

	jmp gameEngineDone

updateSprites:
	; ball ------------------
	lda bally	; y pos
	sta $0200
	lda #$26	; tile number
	sta $0201
	lda #$00	; attrs
	sta $0202
	lda ballx 	; x pos
	sta $0203

	; right paddle ----------
	lda paddle1ytop 	; tile 1
	sta $0204
	lda #$25
	sta $0205
	lda #$00
	sta $0206
	lda #PADDLE1X
	sta $0207

	lda paddle1ytop		 ; tile 2
	clc
	adc #$08
	sta $0208
	lda #$25
	sta $0209
	lda #$00
	sta $020A
	lda #PADDLE1X
	sta $020B

	lda paddle1ytop		 ; tile 3
	clc
	adc #$0F
	sta $020C
	lda #$25
	sta $020D
	lda #$00
	sta $020E
	lda #PADDLE1X
	sta $020F

	lda paddle1ytop		 ; tile 4
	clc
	adc #$17
	sta $0210
	lda #$25
	sta $0211
	lda #$00
	sta $0212
	lda #PADDLE1X
	sta $0213

	; left paddle -----------
	lda paddle2ybot		; tile 1
	sta $0214
	lda #$25
	sta $0215
	lda #$00
	sta $0216
	lda #PADDLE2X
	sta $0217

	lda paddle2ybot		; tile 2
	clc
	adc #$08
	sta $0218
	lda #$25
	sta $0219
	lda #$00
	sta $021A
	lda #PADDLE2X
	sta $021B

	lda paddle2ybot		; tile 3
	clc
	adc #$0F
	sta $021C
	lda #$25
	sta $021D
	lda #$00
	sta $021E
	lda #PADDLE2X
	sta $021F

	lda paddle2ybot		; tile 4
	clc
	adc #$17
	sta $0220
	lda #$25
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
	.byte $0F,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F ; background palette

; =============================================================================
.segment "CHARS"
	.org $0000
	.incbin "mario.chr"
