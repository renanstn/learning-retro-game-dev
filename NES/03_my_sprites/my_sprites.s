; iNES header =================================================================
.segment "HEADER"
	.byte $4E, $45, $53, $1A  	; iNES header identifier ("NES" + $1A)
	.byte $02					; 2x 16KB PRG code
	.byte $01					; 1x  8KB CHR data
	.byte $01, $00				; mapper 0 = NROM, no bank swapping / background mirroring
	; The missing header bytes are set 00 by the assembler

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
buttons1:		.res 1
buttons2:		.res 1
playerX: 		.res 1
playerY: 		.res 1
spritesPointer: .res 2
spriteTile: 	.res 1
NUM_SPRITES 	= $08

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
	lda $2002 		; latch the flag, because we will write two times in $2006 (low and high byte)
	; Load color palette in address $3F00
	lda #$3f 		; high byte
	sta $2006		; write on port
	lda #$00		; low byte
	sta $2006		; write on port

	ldx #$00
LoadPalettesLoop:
	lda paletteData, x
	sta $2007
	inx
	cpx #$20 		; decimal: 16
	bne LoadPalettesLoop

; Init values -----------------------------------------------------------------
	lda #$20
	sta playerX
	lda #$20
	sta playerY
	lda #$00
	sta spritesPointer
	lda #$02
	sta spritesPointer + 1
	lda #$04
	sta spriteTile

; Enable NMI and setup PPU ----------------------------------------------------
finalSettings:
	lda #%10000000 	; Enable NMI and background
         ;||||||||
         ;||||||++-- Base nametable address
         ;||||||     (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
         ;|||||+---- VRAM address increment per CPU read/write of PPUDATA
         ;|||||      (0: add 1, going across; 1: add 32, going down)
         ;||||+----- Sprite pattern table address for 8x8 sprites
         ;||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
         ;|||+------ Background pattern table address (0: $0000; 1: $1000)
         ;||+------- Sprite size (0: 8x8 pixels; 1: 8x16 pixels – see PPU OAM#Byte 1)
         ;|+-------- PPU master/slave select
         ;|          (0: read backdrop from EXT pins; 1: output color on EXT pins)
         ;+--------- Vblank NMI enable (0: off, 1: on)
	sta $2000
	lda #%00011000 	; Setup PPU port: bit 5: enable sprites / bit 4: enable bg
	     ;||||||||
	     ;|||||||+-- Greyscale (0: normal color, 1: greyscale)
	     ;||||||+--- 1: Show background in leftmost 8 pixels of screen, 0: Hide
	     ;|||||+---- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
	     ;||||+----- 1: Enable background rendering
	     ;|||+------ 1: Enable sprite rendering
	     ;||+------- Emphasize red (green on PAL/Dendy)
	     ;|+-------- Emphasize green (red on PAL/Dendy)
	     ;+--------- Emphasize blue
	sta $2001

forever:
	jmp forever

; =============================================================================
nmi:
	; DMA transfer
	lda #$02
	sta $4014

	lda #$00 		; set no background scrolling
	sta $2005
	sta $2005

; All graphics updates done by here, run game engine --------------------------
	jsr readController1
	jsr readController2
	jsr updateSprites
	rti

; Subroutines -----------------------------------------------------------------
updateSprites:
	ldy #$00 	; OAM index, incremented on every step
	ldx #$00	; spriteXOffsets / spriteYOffsets index, incremented on every sprite
updateSpriteLoop:
	lda playerY
	clc
	adc spriteYOffsets, x
	sta (spritesPointer), y
	iny

	lda spriteTiles, x
	sta (spritesPointer), y
	iny

	lda #$00
	sta (spritesPointer), y
	iny

	lda playerX
	clc
	adc spriteXOffsets, x
	sta (spritesPointer), y
	iny
	inx

	cpx #NUM_SPRITES
	bne updateSpriteLoop

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
    ; Background palettes
    .byte $22, $22, $22, $22   ; BG pal 0
    .byte $0F, $0F, $0F, $0F   ; BG pal 1
    .byte $0F, $0F, $0F, $0F   ; BG pal 2
   	.byte $0F, $0F, $0F, $0F   ; BG pal 3

    ; Sprite palettes
    .byte $0F, $16, $28, $0F   ; SPR pal 0
    .byte $0F, $0F, $0F, $0F   ; SPR pal 1
    .byte $0F, $0F, $0F, $0F   ; SPR pal 2
    .byte $0F, $0F, $0F, $0F   ; SPR pal 3

spriteXOffsets:
	.byte $00, $08, $00, $08, $00, $08, $00, $08

spriteYOffsets:
	.byte $00, $00, $08, $08, $0F, $0F, $17, $17

spriteTiles:
	.byte $04, $05, $14, $15, $24, $25, $34, $35

backgroundData:
attributeData:

; =============================================================================
.segment "CHARS"
	.org $0000 			; chr data will be loaded at $0000 address
	.incbin "test8.chr"
