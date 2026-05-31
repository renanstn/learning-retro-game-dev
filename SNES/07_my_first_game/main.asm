.p816
.smart

.include "registers.asm"
.include "variables.asm"
.include "macros.asm"
.include "init.asm"

; -----------------------------------------------------------------------------
.segment "CODE"

InitPlayer:
    AXY8
    lda #120
    sta PlayerX
    lda #184
    sta PlayerY
    rts

DrawPlayer:
    AXY8
    ldx #0      ; metasprite index
    ldy #0      ; OAM index
@Loop:
    ; X
    lda MetaSprite, x
    clc
    adc PlayerX
    sta OAM_BUFFER, y
    inx
    iny
    ; Y
    lda MetaSprite, x
    clc
    adc PlayerY
    sta OAM_BUFFER, y
    inx
    iny
    ; TILE
    lda MetaSprite, x
    sta OAM_BUFFER, y
    inx
    iny
    ; ATTR
    lda MetaSprite, x
    sta OAM_BUFFER, y
    inx
    iny
    ; Check end
    cpx #MetaSpriteSize
    bcc @Loop
    rts

; Enters here in forced blank -------------------------------------------------
Main:
.a16                ; set A to 16 bit size
.i16                ; set XY to 16 bit size
    phk             ; sets the Data Bank Register to the same as the Program Bank
    plb             ; sets the Data Bank Register to the same as the Program Bank

; DMA from BG Palette to CGRAM ------------------------------------------------
    A8                  ; put the A register in 8 bit mode
    stz CGADD           ; point to CGRAM address zero
    DMA_CGRAM $22, BG_Palette, (End_BG_Palette-BG_Palette)

; DMA from Sprite Palette to CGRAM --------------------------------------------
    lda #$80
    sta CGADD           ; point to CGRAM address zero
    DMA_CGRAM $22, OB_Palette, (End_OB_Palette-OB_Palette)

; DMA from Bg Tiles do VRAM ---------------------------------------------------
    DMA_VRAM $0000, BG_Tiles, (End_BG_Tiles-BG_Tiles)

; DMA from Sprite Tiles do VRAM -----------------------------------------------
    DMA_VRAM $4000, OB_Tiles, (End_OB_Tiles-OB_Tiles)

; DMA from BG Tilemap to VRAM -------------------------------------------------
    DMA_VRAM $6000, BG_Tilemap, (End_BG_Tilemap-BG_Tilemap)

; Init player vars ------------------------------------------------------------
	jsr InitPlayer

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

    ; turn on NMI interrupts and auto-controller reads
	lda #NMI_ON|AUTO_JOY_ON
	sta NMITIMEN

; Turn the screen on (end forced blank) ---------------------------------------
lda #FULL_BRIGHT    ; $0f - full brightness
sta INIDISP         ; $2100 - effectively turns the screen ON

; Game loop -------------------------------------------------------------------
Infinite_Loop:
    A8
    XY16
    jsr Wait_NMI
    ; We are now in v-blank
    jsr Pad_Poll
    AXY16
    ; Move player left
    lda pad1
    and #KEY_LEFT
    beq @not_left
@left:
    A8
    dec PlayerX
    A16
@not_left:
    ; Move player right
    lda pad1
    and #KEY_RIGHT
    beq @not_right
@right:
    A8
    inc PlayerX
    A16
@not_right:

    ; Render ------------------------------------------------------------------
    jsr DrawPlayer
    jsr DMA_OAM         ; DMA from OAM_BUFFER to the OAM RAM

    jmp Infinite_Loop

; Functions -------------------------------------------------------------------
Wait_NMI:
    .a8
    .i16
    ;should work fine regardless of size of A
	lda in_nmi      ;load A register with previous in_nmi
    @check_again:
	WAI             ;wait for an interrupt
	cmp in_nmi	    ;compare A to current in_nmi
				    ;wait for it to change
					;make sure it was an nmi interrupt
	beq @check_again
	rts

;------------------------------------------------------------------------------
Pad_Poll:
    .a8
    .i16
    ; reads both controllers to pad1, pad1_new, pad2, pad2_new
    ; auto controller reads done, call this once per main loop
    ; copies the current controller reads to these variables
    ; pad1, pad1_new, pad2, pad2_new (all 16 bit)
	php
	A8
@wait:          ; wait till auto-controller reads are done
	lda HVBJOY  ; check HBlank, VBlank and JoypadBusy status
	lsr a
	bcs @wait

	A16         ; put A to 16 bit, so we can read all buttons at once
	; joypad 1
	lda pad1
	sta temp1   ; save last frame
	lda JOY1L   ; $4218: controller 1 low
	sta pad1
	eor temp1
	and pad1
	sta pad1_new

	; joypad 2
	lda pad2
	sta temp1   ; save last frame
	lda JOY2L   ; $421a: controller 2 low
	sta pad2
	eor temp1
	and pad2
	sta pad2_new
	plp
	rts

; -----------------------------------------------------------------------------
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

MetaSprite:
.byte $F8, $E8, $00, SPR_PRIOR_2
.byte $00, $E8, $01, SPR_PRIOR_2
.byte $F8, $F0, $10, SPR_PRIOR_2
.byte $00, $F0, $11, SPR_PRIOR_2
.byte $F8, $F8, $20, SPR_PRIOR_2
.byte $00, $F8, $21, SPR_PRIOR_2
.byte $08, $F8, $22, SPR_PRIOR_2
.byte $00, $00, $31, SPR_PRIOR_2
.byte $08, $00, $32, SPR_PRIOR_2
End_MetaSprite:

MetaSpriteSize = End_MetaSprite - MetaSprite
