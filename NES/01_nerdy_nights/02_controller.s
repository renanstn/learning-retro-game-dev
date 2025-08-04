.segment "HEADER"
	.byte $4E, $45, $53, $1A  	; iNES header identifier
	.byte $02					; 2x 16KB PRG code
	.byte $01					; 1x  8KB CHR data
	.byte $01, $00				; mapper 0 = NROM, no bank swapping / background mirroring

; =============================================================================
.segment "VECTORS"
	; When an NMI happens (once per frame if enabled) the label nmi:
	.addr nmi
	; When the processor first turns on or is reset, it will jump to the label reset:
	.addr reset
	; External interrupt IRQ (unused)
	.addr 0

; =============================================================================
.segment "STARTUP"
; nes linker config requires a STARTUP section, even if its empty

; =============================================================================
.segment "CODE"
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

vblankwait1: 		; first wait for vblank to make sure PPU is ready ---------
	bit $2002
	bpl vblankwait1

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

vblankwait2: 		; second wait for vblank, PPU is ready after this ---------
	bit $2002
	bpl vblankwait2

; Setup sprite palettes -------------------------------------------------------
	lda $2002
	; Lets create a sprite palette ($3F10)
	lda #$3f 		; high byte
	sta $2006		; write on port
	lda #$10		; low byte
	sta $2006		; write on port
; Load palettes loop ----------------------------------------------------------
	ldx #$00
LoadPalettesLoop:
	lda paletteData, x
	sta $2007
	inx
	cpx #$20
	bne LoadPalettesLoop

; Draw mario loop -------------------------------------------------------------
LoadSprites:
	ldx #$00 		; loop index
LoadSpritesLoop:
	lda sprites, x
	sta $0200, x
	inx
	cpx #$20
	bne LoadSpritesLoop

; -----------------------------------------------------------------------------
; Setup PPU port
	lda #%00010000 	; activate sprites
	sta $2001

; Enable NMI
	lda #%10000000
	sta $2000

forever:
	jmp forever  	; infinite loop

; =============================================================================
nmi:
	; Here the DMA happens, transfering all sprites from RAM to OAM -----------
	lda #$02
	sta $4014

; Read gamepad buttons --------------------------------------------------------
LatchController:
	lda #$01
	sta $4016
	lda #$00
	sta $4016 		; tell both the controllers to latch buttons

; Left and right buttons are the 7 and 8 values, so we ignore the first 6
ldx #$06
ReadButtonsLoop: ; ------------------------------------------------------------
	lda $4016
	and #%00000001 	; only the last bit matters
	dex
	bne ReadButtonsLoop

; Check left buttom pressed ---------------------------------------------------
	LDA $4016		; Value #7
	and #%00000001
	beq ReadLeftDone
	; Move sprite 1 location
	lda $0203		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$02		; decrement
	sta $0203		; save sprite X position
	; Move sprite 2 location
	lda $0207		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$02		; decrement
	sta $0207		; save sprite X position
	; Move sprite 3 location
	lda $020B		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$02		; decrement
	sta $020B		; save sprite X position
	; Move sprite 4 location
	lda $020F		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$02		; decrement
	sta $020F		; save sprite X position
	jmp DoneCheckingButtons
ReadLeftDone:

; Check right buttom pressed --------------------------------------------------
	LDA $4016		; Value #8
	and #%00000001
	beq ReadRightDone
	; Move sprite 1 location
	lda $0203		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$02		; increment
	sta $0203		; save sprite X position
	; Move sprite 2 location
	lda $0207		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$02		; increment
	sta $0207		; save sprite X position
	; Move sprite 3 location
	lda $020B		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$02		; increment
	sta $020B		; save sprite X position
	; Move sprite 4 location
	lda $020F		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$02		; increment
	sta $020F		; save sprite X position
	jmp DoneCheckingButtons
ReadRightDone:

DoneCheckingButtons:

rti

; =============================================================================
.segment "RODATA"
paletteData:
	.byte $0F,$1C,$15,$14, $0F,$02,$38,$3C, $0F,$1C,$15,$14, $0F,$02,$38,$3C
	.byte $0F,$31,$32,$33, $0F,$35,$36,$37, $0F,$39,$3A,$3B, $0F,$3D,$3E,$0F

sprites:
	;     vert|tile|attr|horiz
	.byte $80, $32, $00, $80   	;sprite 0
	.byte $80, $33, $00, $88   	;sprite 1
	.byte $88, $34, $00, $80   	;sprite 2
	.byte $88, $35, $00, $88   	;sprite 3

; =============================================================================
.segment "CHARS"
	.org $0000
	; includes 8KB graphics file from SMB1
	.incbin "mario.chr"
