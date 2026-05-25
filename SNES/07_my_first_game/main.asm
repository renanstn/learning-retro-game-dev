.p816
.smart

.include "registers.asm"
.include "variables.asm"
.include "macros.asm"
.include "init.asm"

; -----------------------------------------------------------------------------
.segment "ZEROPAGE"

; -----------------------------------------------------------------------------
.segment "CODE"

; Enters here in forced blank -------------------------------------------------
Main:
.a16                ; set A to 16 bit size
.i16                ; set XY to 16 bit size
    phk             ; sets the Data Bank Register to the same as the Program Bank
    plb             ; sets the Data Bank Register to the same as the Program Bank

; DMA from BG Palette to CGRAM ------------------------------------------------
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

; COPY sprites to sprite buffer
	BLOCK_MOVE (End_Sprite-Sprite), Sprite, OAM_BUFFER
	A8

; DMA from OAM_BUFFER to the OAM RAM
	jsr DMA_OAM

; DMA from Sprite Palette to CGRAM --------------------------------------------
    lda #$80
    sta CGADD           ; point to CGRAM address zero

    stz $4300           ; transfer mode 0 = 1 register write once
    lda #$22            ; $2122
    sta $4301           ; destination, CGRAM data
    ldx #.loword(OB_Palette)
    stx $4302           ; source
    lda #^OB_Palette
    sta $4304           ; bank
    ldx #(End_OB_Palette-OB_Palette)
    stx $4305           ; length
    lda #1
    sta $420b           ; start DMA, channel 0

; DMA from Bg Tiles do VRAM ---------------------------------------------------
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
    ldx #.loword(BG_Tiles)
    stx $4302           ; source
    lda #^BG_Tiles
    sta $4304           ; bank
    ldx #(End_BG_Tiles-BG_Tiles)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

; DMA from Sprite Tiles do VRAM -----------------------------------------------
    lda #V_INC_1
    sta VMAIN           ; $2115 = set the increment mode +1
    ldx #$4000
    stx VMADDL          ; $2116 set an address in the vram

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
                        ; $2118 and $2119 are a pair Low/High
    lda #$18            ; $2118
    sta $4301           ; destination: vram data
    ldx #.loword(OB_Tiles)
    stx $4302           ; source
    lda #^OB_Tiles
    sta $4304           ; bank
    ldx #(End_OB_Tiles-OB_Tiles)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

; DMA from BG Tilemap to VRAM -------------------------------------------------
    ldx #$6000
    stx VMADDL          ; $2116 set an address in the vram of $6000

    lda #1
    sta $4300           ; transfer mode, 2 registers 1 write
    lda #$18            ; $2118
    sta $4301           ; destination, vram data
    ldx #.loword(BG_Tilemap)
    stx $4302           ; source
    lda #^BG_Tilemap
    sta $4304           ; bank
    ldx #(End_BG_Tilemap-BG_Tilemap)
    stx $4305           ; length
    lda #1
    sta $420b           ; start transfer

; Screen mode and other configs -----------------------------------------------
    lda #2              ;sprite tiles at $4000
	sta OBSEL

    lda #1              ; BG mode 1, tilesize 8x8 all
    sta BGMODE

    stz BG12NBA         ; BG in VRAM address: $0000

    lda #$60            ; bg1 map at VRAM address $6000
    sta BG1SC

    lda #(BG1_ON | SPR_ON) ; activate background and sprites
    sta TM

; Turn the screen on (end forced blank) ---------------------------------------
lda #FULL_BRIGHT    ; $0f - full brightness
sta INIDISP         ; $2100 - effectively turns the screen ON

Infinite_Loop:
    jmp Infinite_Loop

.include "header.asm"
.include "vectors.asm"

; -----------------------------------------------------------------------------
.segment "RODATA"

BG_Palette:
.incbin "palette.pal"
End_BG_Palette:

BG_Tiles:
.incbin "tiles.chr"
End_BG_Tiles:

BG_Tilemap:
.incbin "tilemap.map"
End_BG_Tilemap:

OB_Palette:
.incbin "sprite_palette.pal"
End_OB_Palette:

OB_Tiles:
.incbin "sprite_tiles.chr"
End_OB_Tiles:

Sprite:
.byte $80, $A0, $00, SPR_PRIOR_2
.byte $88, $A0, $01, SPR_PRIOR_2
.byte $80, $A8, $10, SPR_PRIOR_2
.byte $88, $A8, $11, SPR_PRIOR_2
.byte $80, $B0, $20, SPR_PRIOR_2
.byte $88, $B0, $21, SPR_PRIOR_2
.byte $90, $B0, $22, SPR_PRIOR_2
.byte $88, $B8, $31, SPR_PRIOR_2
.byte $90, $B8, $32, SPR_PRIOR_2
End_Sprite:
