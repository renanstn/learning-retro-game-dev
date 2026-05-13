.p816
.smart

.include "registers.asm"
.include "variables.asm"
.include "macros.asm"
.include "init.asm"

.segment "CODE"

; Enters here in forced blank
Main:
.a16                    ; set A to 16 bit size
.i16                    ; set XY to 16 bit size
    phk                 ; sets the Data Bank Register to the same as the Program Bank
    plb                 ; sets the Data Bank Register to the same as the Program Bank

; DMA from BG_Palette to CGRAM ------------------------------------------------
    A8                  ; put the A register in 8 bit mode
    stz CGADD           ; point to CGRAM address zero
    stz $4300           ; transfer mode 0 = 1 register write once
    lda #$22            ; $2122
    sta $4301           ; destination, CGRAM data
    ldx #.loword(BG_Palette)
    stx $4302           ; source
    lda #^BG_Palette
    sta $4304           ; bank
    ldx #32             ; BG_Palette size
    stx $4305           ; length
    lda #1
    sta $420b           ; start dma, channel 0

; DMA from Tiles do VRAM ------------------------------------------------------
    lda #V_INC_1        ; the value $80
    ; each write will go +1 the previous write address
    sta VMAIN           ; $2115 = set the increment mode +1
    ldx #$0000
    stx VMADDL          ; $2116 set an address in the vram of $0000

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
                        ; $2118 and $2119 are a pair Low/High
    lda #$18            ; $2118
    sta $4301           ; destination: vram data
    ldx #.loword(Tiles)
    stx $4302           ; source
    lda #^Tiles
    sta $4304           ; bank
    ldx #(End_Tiles-Tiles)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

; DMA from Tilemap to VRAM ----------------------------------------------------
    ldx #$6000
    stx VMADDL          ; $2116 set an address in the vram of $6000

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
    lda #$18            ; $2118
    sta $4301           ; destination, vram data
    ldx #.loword(Tilemap)
    stx $4302           ; source
    lda #^Tilemap
    sta $4304           ; bank
    ldx #(End_Tilemap-Tilemap)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

    ; -------------------------------------------------------------------------
    lda #1              ; BG mode 1, tilesize 8x8 all
    sta BGMODE

    stz BG12NBA         ; $210b tiles for BG 1+2 at VRAM address $0000

    lda #$60            ; bg1 map at VRAM address $6000
    sta BG1SC

    lda #BG1_ON         ; $01 = only bg 1 is active
    sta TM

; turn the screen on (end forced blank) ---------------------------------------
	lda #FULL_BRIGHT    ; $0f - full brightness
	sta INIDISP         ; $2100 - effectively turns the screen ON

Infinite_Loop:
    jmp Infinite_Loop

.include "header.asm"

; -----------------------------------------------------------------------------
.segment "RODATA1"

BG_Palette:
.incbin "snes.palette"

Tiles:
.incbin "snes.tiles"
End_Tiles:

Tilemap:
.incbin "snes.map"
End_Tilemap:
