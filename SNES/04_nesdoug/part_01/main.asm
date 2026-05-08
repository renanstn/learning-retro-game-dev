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
; ------------------------------------------------------------------------------------
    stz CGADD           ; $2121 set color address to 0
                        ; HERE we're indicating that we will paint the palette index 0
    lda #$1f            ; palette low byte gggrrrrr
                        ; 1f = all the red bits
    sta CGDATA          ; $2122 - write the low byte
    lda #$00            ; palette high byte -bbbbbgg
    sta CGDATA          ; $2122 - write the high byte to the palette
; ------------------------------------------------------------------------------------
; turn the screen on (end forced blank)
	lda #FULL_BRIGHT    ; $0f - full brightness
	sta INIDISP         ; $2100 - effectively turns the screen ON

Infinite_Loop:
    jmp Infinite_Loop

.include "header.asm"
