; macros for SNES

.macro A8
	sep #$20
.endmacro

.macro A16
	rep #$20
.endmacro

.macro AXY8
	sep #$30
.endmacro

.macro AXY16
	rep #$30
.endmacro

.macro XY8
	sep #$10
.endmacro

.macro XY16
	rep #$10
.endmacro

; memcpy, block move
;for WRAM to WRAM data transfers (can't be done with DMA)
.macro BLOCK_MOVE  length, src_addr, dst_addr
;mnv changes the data bank register, need to preserve it
	phb
.if .asize = 8
	rep #$30
.elseif .isize = 8
	rep #$30
.endif
	lda #(length-1)
	ldx #.loword(src_addr)
	ldy #.loword(dst_addr)
;	mvn src_bank, dst_bank
	.byte $54, ^dst_addr, ^src_addr
	plb
.endmacro

.macro DMA_CGRAM destination, source, size
    stz $4300               ; transfer mode 0 = 1 register write once

    lda #destination
    sta $4301               ; destination

    ldx #.loword(source)
    stx $4302               ; source

    lda #^source
    sta $4304               ; bank

    ldx #size
    stx $4305               ; length

    lda #1
    sta $420B               ; start DMA, channel 0
.endmacro

.macro DMA_VRAM destination, source, size
    lda #V_INC_1
    sta VMAIN               ; each write will go +1 the previous write address

    ldx #destination
    stx VMADDL

    lda #1
    sta $4300               ; transfer mode, 2 registers 1 write

    lda #$18
    sta $4301

    ldx #.loword(source)
    stx $4302               ; source

    lda #^source
    sta $4304               ; bank

    ldx #size
    stx $4305               ; length

    lda #1
    sta $420B               ; start DMA, channel 0
.endmacro
