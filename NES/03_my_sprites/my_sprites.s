; My game =====================================================================
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
pointerLo: 		.res 1 	; used in background load loop
pointerHi: 		.res 1	; used in background load loop
buttons1:		.res 1
buttons2:		.res 1

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

	lda #$00 	; set no background scrolling
	sta $2005
	sta $2005

; All graphics updates done by here, run game engine --------------------------
	jsr readController1
	jsr readController2
	jsr updateSprites
	rti

; Subroutines -----------------------------------------------------------------
updateSprites:
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
	.byte $0F,$37,$24,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F ; sprite palette
	.byte $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F ; background palette

backgroundData:
attributeData:

; =============================================================================
.segment "CHARS"
	.org $0000 			; chr data will be loaded at $0000 address
	.incbin "test5.chr"
