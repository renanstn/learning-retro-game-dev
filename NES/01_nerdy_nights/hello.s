.segment "HEADER"
	.byte $4E, $45, $53, $1A  	; iNES header identifier
	.byte 1						; 1x 16KB PRG code
	.byte 1						; 1x  8KB CHR data
	.byte $01, $00				; mapper 0 = NROM, no bank swapping / background mirroring

.segment "VECTORS"
	; When an NMI happens (once per frame if enabled) the label nmi:
	.addr nmi
	; When the processor first turns on or is reset, it will jump to the label reset:
	.addr reset
	; External interrupt IRQ (unused)
	.addr 0

.segment "STARTUP"
; nes linker config requires a STARTUP section, even if its empty

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

; first wait for vblank to make sure PPU is ready
vblankwait1:
	bit $2002
	bpl vblankwait1

clear_memory:
	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clear_memory

; second wait for vblank, PPU is ready after this
vblankwait2:
	bit $2002
	bpl vblankwait2

; now the code that really do the rainbow magic
	lda #%10000000   ; intensify blues
	sta $2001

forever:
	jmp forever    	 ; infinite loop
 
nmi:
	rti
 
.segment "CHARS"
	.org $0000
	.incbin "mario.chr"   ;includes 8KB graphics file from SMB1
