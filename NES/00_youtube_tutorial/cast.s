.segment "HEADER"
	.byte "NES"        	; identification string, all NES roms need it
	.byte $1A
	.byte $02          	; amount of PRG ROM in 16k units
	.byte $01          	; amount of PRG ROM in 8k units
	.byte $00 			; mapper and mirroing
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
VAR: .RES 1 			; reserves 1 byte of memory for a variable named VAR

.segment "STARTUP"
RESET:
	SEI 				; disables interrupts
	CLD 				; turn off decimal mode

	LDX #%1000000 		; disable sound IRQ
	STX $4017
	LDX #$00
	STX $4010 			; disable PCM

	; init the stack register
	LDX #$FF
	TXS 				; transfer to the stack

:
	; clear PPU registers
	LDX #$00
	STX $2000
	STX $2001

	; Wait for vblank
:
	BIT $2002
	BPL:-

	; Clearing 2k memory
	TXA
CLEARMEMORY: 			; from $0000 to $07FF
	STA $0000, X
	STA $0100, X
	STA $0200, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X
	INX
	CPX #$00
	BNE CLEARMEMORY

	INFLOOP:
		JMP INFLOOP
NMI:
	RTI

.segment "VECTORS"
	.word NMI
	.word RESET
	; specialized wardware interrupts

.segment "CHARS"
	.incbin "rom.chr"
