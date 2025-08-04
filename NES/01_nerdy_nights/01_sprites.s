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

clear_memory:
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
	bne clear_memory

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

; Draw a sprite ---------------------------------------------------------------
	lda #$80 		; lets create a sprite in x:80 and y:80
	sta $0200 		; y
	sta $0203		; x
	lda #$00		; tile number 00
	sta $0201 		; set tile number
	lda #$00 		; tile attrs
	sta $0202 		; set tile attrs
; Lets draw another sprite ----------------------------------------------------
	lda #$80		; y
	sta $0204 		; y
	lda #$88		; x
	sta $0207		; x
	lda #$01		; tile number
	sta $0205 		; set tile number
	lda #$00 		; tile attrs
	sta $0206 		; set tile attrs
; Lets draw another sprite ----------------------------------------------------
	lda #$88		; y
	sta $0208 		; y
	lda #$80		; x
	sta $020B		; x
	lda #$02		; tile number
	sta $0209 		; set tile number
	lda #$00 		; tile attrs
	sta $020A 		; set tile attrs
; Lets draw another sprite ----------------------------------------------------
	lda #$88		; y
	sta $020C 		; y
	lda #$88		; x
	sta $020F		; x
	lda #$03		; tile number
	sta $020D 		; set tile number
	lda #$00 		; tile attrs
	sta $020E 		; set tile attrs

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
	; Here the DMA happens, transfering all sprites from RAM to OAM
	lda #$02
	sta $4014
	rti

; =============================================================================
.segment "RODATA"
paletteData:
	.byte $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
	.byte $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

; =============================================================================
.segment "CHARS"
	.org $0000
	; includes 8KB graphics file from SMB1
	.incbin "mario.chr"
