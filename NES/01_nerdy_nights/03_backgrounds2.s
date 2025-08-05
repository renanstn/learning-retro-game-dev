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
.segment "ZEROPAGE"
pointerLo: .res 1 	; used in background load loop
pointerHi: .res 1	; used in background load loop

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
	cpx #$20 			; Compare X to decimal 16
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
	lda #%10010000 	; Enable NMI and background
	sta $2000

	lda #%00011110	; Setup PPU port: enable sprites and bg
	sta $2001

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
	sbc #$01		; decrement
	sta $0203		; save sprite X position
	; Move sprite 2 location
	lda $0207		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$01		; decrement
	sta $0207		; save sprite X position
	; Move sprite 3 location
	lda $020B		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$01		; decrement
	sta $020B		; save sprite X position
	; Move sprite 4 location
	lda $020F		; load sprite X position
	sec				; make sure the carry flag is set
	sbc #$01		; decrement
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
	adc #$01		; increment
	sta $0203		; save sprite X position
	; Move sprite 2 location
	lda $0207		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$01		; increment
	sta $0207		; save sprite X position
	; Move sprite 3 location
	lda $020B		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$01		; increment
	sta $020B		; save sprite X position
	; Move sprite 4 location
	lda $020F		; load sprite X position
	clc				; make sure the carry flag is clear
	adc #$01		; increment
	sta $020F		; save sprite X position
	jmp DoneCheckingButtons
ReadRightDone:

DoneCheckingButtons:

	lda #$00        ; tell the ppu there is no background scrolling
	sta $2005
	sta $2005
rti

; =============================================================================
.segment "RODATA"
paletteData:
	.byte $22,$16,$36,$0F,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C ; sprite palette
	.byte $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F ; background palette

sprites: ; vert pos | tile number | attr | horizontal pos
	.byte $80, $32, $00, $80   	;sprite 0
	.byte $80, $33, $00, $88   	;sprite 1
	.byte $88, $34, $00, $80   	;sprite 2
	.byte $88, $35, $00, $88   	;sprite 3

backgroundData: ; all screen: 30 rows * 2
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 2
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 3
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 4
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 5
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 6
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 7
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 8
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 9
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 10
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 11
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 12
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 13
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 14
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24  ;;row 15
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24  ;;row 16
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 17
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 18
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45  ;;row 19
	.byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45  ;;some brick tops

	.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47  ;;row 20
	.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47  ;;floor

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 21
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 22
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 23
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 24
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 25
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 26
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 27
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 28
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 29
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 30
	.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky


attributeData:  ;8 x 8 = 64 bytes
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %01010000, %01010000, %01010000, %01010000, %01010000, %01010000, %01010000, %01010000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000

; =============================================================================
.segment "CHARS"
	.org $0000
	; includes 8KB graphics file from SMB1
	.incbin "mario.chr"
