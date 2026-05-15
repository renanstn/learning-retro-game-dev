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
    ldx #(End_BG_Palette-BG_Palette)
    stx $4305           ; length
    lda #1
    sta $420b           ; start DMA, channel 0

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

; DMA from BG_Palette2 to CGRAM -----------------------------------------------
    lda #$C0            ; calculated position of the next palette
    sta CGADD           ; point to CGRAM address

    stz $4300           ; transfer mode 0 = 1 register write once
    lda #$22            ; $2122
    sta $4301           ; destination, CGRAM data
    ldx #.loword(BG_Palette2)
    stx $4302           ; source
    lda #^BG_Palette2
    sta $4304           ; bank
    ldx #(End_BG_Palette2-BG_Palette2)
    stx $4305           ; length
    lda #1
    sta $420b           ; start DMA, channel 0

; DMA from Tiles2 do VRAM -----------------------------------------------------
    lda #V_INC_1        ; the value $80
    ; each write will go +1 the previous write address
    sta VMAIN           ; $2115 = set the increment mode +1
    ldx #$4000
    stx VMADDL          ; set an address in the vram

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
                        ; $2118 and $2119 are a pair Low/High
    lda #$18            ; $2118
    sta $4301           ; destination: vram data
    ldx #.loword(Tiles2)
    stx $4302           ; source
    lda #^Tiles2
    sta $4304           ; bank
    ldx #(End_Tiles2-Tiles2)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

; DMA from Tilemap2 to VRAM ---------------------------------------------------
    ldx #$6800
    stx VMADDL          ; set an address in the vram

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
    lda #$18            ; $2118
    sta $4301           ; destination, vram data
    ldx #.loword(Tilemap2)
    stx $4302           ; source
    lda #^Tilemap2
    sta $4304           ; bank
    ldx #(End_Tilemap2-Tilemap2)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

    ; -------------------------------------------------------------------------
    lda #1              ; BG mode 1, tilesize 8x8 all
    sta BGMODE

    ;lda #$40
    lda #$04
    sta BG12NBA
    ;stz BG12NBA         ; $210b tiles for BG 1+2 at VRAM address $0000
    ;lda #$03
    ;sta BG24NBA

    ;lda #$60            ; bg1 map at VRAM address $6000
    lda #$68            ; bg1 map at VRAM address $6000
    sta BG1SC
    ;lda #$68            ; bg2 map at VRAM address $6800
    lda #$60            ; bg2 map at VRAM address $6800
    sta BG2SC

    ;lda #BG1_ON         ; $01 = only bg 1 is active
    ;lda #BG_ALL_ON      ; all bgs active
    lda #%00000011       ; bg 1 and 2 active
    sta TM

; Turn the screen on (end forced blank) ---------------------------------------
	lda #FULL_BRIGHT    ; $0f - full brightness
	sta INIDISP         ; $2100 - effectively turns the screen ON

Infinite_Loop:
    jmp Infinite_Loop

.include "header.asm"

; -----------------------------------------------------------------------------
.segment "RODATA1"

BG_Palette:
.incbin "snes_01.palette"
End_BG_Palette:

Tiles:
.incbin "snes_01.tiles"
End_Tiles:

Tilemap:
.incbin "snes_01.map"
End_Tilemap:

; -----------------------------------------------------------------------------
.segment "RODATA2"

BG_Palette2:
.incbin "snes_02.palette"
End_BG_Palette2:

Tiles2:
.incbin "snes_02.tiles"
End_Tiles2:

Tilemap2:
.incbin "snes_02.map"
End_Tilemap2:
