.p816                   ; puts the assembler in 65816 mode
.smart                  ; tell the assembler to automatically adjust register size depending on REP / SEP changes (handled through macros like A8, AXY16, etc)

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

    A8                  ; put the A register in 8 bit mode
    XY16
; ------------------------------------------------------------------------------
stz CGADD               ; point to CGRAM address zero

; Setup palette via DMA
stz $4300               ; transfer mode 0 = 1 register write once
lda #$22                ; $2122
sta $4301               ; destination, CGRAM data
ldx #.loword(BG_Palette)
stx $4302               ; source
lda #^BG_Palette
sta $4304               ; bank
ldx #256                ; BG_Palette only has 128 colors, 2 bytes each
stx $4305               ; length
lda #1
sta $420b               ; start dma, channel 0

; This will transfer all the 128 colors from default.pal to CGRAM
; The first 128 colors are the BG palette
; The last 128 colors are the sprite palette, so we will run this DMA twice:

ldx #.loword(BG_Palette)
stx $4302               ; source
lda #^BG_Palette
sta $4304               ; bank
ldx #256                ; sprite Palette has 128 colors, 2 bytes each
stx $4305               ; length
lda #1
sta $420b               ; start dma, channel 0
; ------------------------------------------------------------------------------

; turn the screen on (end forced blank)
	lda #FULL_BRIGHT    ; $0f - full brightness
	sta INIDISP         ; $2100 - effectively turns the screen ON

; note, nothing is active on the main screen,
; so only the main background color will show.

Infinite_Loop:
    jmp Infinite_Loop

.include "header.asm"

; ------------------------------------------------------------------------------
.segment "RODATA1"

BG_Palette:
.incbin "default.pal"
