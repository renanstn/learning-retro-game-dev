.p816 					; set compilation mode for 65816
.smart					; make assembler optimize code when possible

.include "macros.inc"
.include "registers.inc"

.include "header.asm"

.segment "CODE"
start:
	.include "init.asm"

	; Set up the color palette
	stz CGADD
	; Set color zero to red
	; $001f = %0000000000011111
	;           bbbbbgggggrrrrr
	lda #$00
	sta CGDATA
	lda #$F8
	sta CGDATA

	lda #$0f
	sta INIDISP

busywait:
	bra busywait

nmi:
	bit RDNMI
_rti:
	rti
