# NES

TODO: Organizar melhor isso

## Anotações guia nerdy nights

O NES possui um chip 6502 customizado.

- ROM - Read Only Memory, holds data that cannot be changed. This is where the game code or graphics is stored on the cart.
- RAM - Random Access Memory, holds data that can be read and written. When power is removed, the chip is erased. A battery can be used to keep power and data valid.
- PRG - Program memory, the code for the game
- CHR - Character memory, the data for graphics
- CPU - Central Processing Unit, the main processor chip
- PPU - Picture Processing Unit, the graphics chip
- APU - Audio Processing Unit, the sound chip inside the CPU

Endereços são 4 dígitos, sempre seguidos de `$`.

### PPU

- If there are more than 8 sprites on the scanline the rest are ignored.
- Both the NTSC and PAL systems have a resolution of 256x240 pixels, but the top and bottom 8 rows are typically cut off by the NTSC TV resulting in 256x224.
- NTSC runs at 60Hz and PAL runs at 50Hz. Running an NTSC game on a PAL system will be slower because of this timing difference. Sounds will also be slower.

### Graphics System

- **Tiles**: 8x8 pixels
- **Sprites**: É tudo que se move. Cabem 64 sprites na memória. Apenas 8 sprites por scanline são permitidos.
- **Background**: Pode ser scrollado. Pode ser exibido na frente ou atrás do background. Em uma tela cabem 32x30 bg tiles. Há espaço interno para armazenar 2 telas ao mesmo tempo.
- **Pattern Tables**: É onde todos os tile data ficam guardados. Cabem 256 tiles em uma table. Uma table é usada para sprites, e outra para backgrounds.
- **Attribute Tables**: Armazenam informações de cores em 2x2 tile sections. Isso significa que uma área de 16x16 pixels só podem ter 4 cores diferentes.
- **Palletes**: São duas áreas que armazenam informações de cores, uma para o bg, outra para os sprites. Cada paleta tem *16 cores*.

To display a tile on screen, the pixel color index is taken from the Pattern Table and the Attribute Table. That index is then looked up in the Palette to get the actual color.

### 6502

- Material de apoio: https://skilldrick.github.io/easy6502/

#### Glossário

- **Directives**: São comandos enviados para o *assembler* para fazer coisas, como achar algo na memória. Eles começam com `.`, e são identados. Exemplo: `.org $8000`.
- **Labels**: A label fica alinhada com a margem esquerda, serve para organizar o código. O assembler traduz as label para endereços. Ex: `MyFunction:`.
- **OPcodes**: É uma instrução, como `JMP`.
- **Operands**: Informações adicionais aos opcodes, cada opcode pode ter entre 1 e 3 operandos. Exemplo: `LDA #$FF`.
- **Comments**: O bom e velho `;`.

#### Memória

`$0000-0800` - Internal RAM, 2KB chip in the NES
`$2000-2007` - PPU access ports
`$4000-4017` - Audio and controller access ports
`$6000-7FFF` - Optional WRAM inside the game cart
`$8000-FFFF` - Game cart ROM

O chip possui 56 instruções. 10 são usadas geralmente.

- Se um valor começa com `#`, significa o número atual de fato.
- Caso não tenha `#`, trata-se de um endereço.

```
LDA #$05 means load the value 5
LDA $0005 means load the value that is stored at address $0005
```

#### Registradores

O 6502 possui 3 registers de 8 bit + 1 status register. (Na vdd tem mais, mas o tutorial ignora)

- **A**: Accumulator, aquele usado nas operações matemáticas
- **X**: Usado para contagens, loops, ou memory access.
- **Y**: Igual o X. Mas algumas instruções funcionam só com o X.
- **Status register**: É aquele que armazena as flags de operações (result was zero)

#### Instruções básicas

```
LDA #$0A   ; LoaD the value 0A into the accumulator A
           ; the number part of the opcode can be a value or an address
           ; if the value is zero, the zero flag will be set.

LDX $0000  ; LoaD the value at address $0000 into the index register X
           ; if the value is zero, the zero flag will be set.

LDY #$FF   ; LoaD the value $FF into the index register Y
           ; if the value is zero, the zero flag will be set.

STA $2000  ; STore the value from accumulator A into the address $2000
           ; the number part must be an address

STX $4016  ; STore value in X into $4016
           ; the number part must be an address

STY $0101  ; STore Y into $0101
           ; the number part must be an address

TAX        ; Transfer the value from A into X
           ; if the value is zero, the zero flag will be set

TAY        ; Transfer A into Y
           ; if the value is zero, the zero flag will be set

TXA        ; Transfer X into A
           ; if the value is zero, the zero flag will be set

TYA        ; Transfer Y into A
           ; if the value is zero, the zero flag will be set
```

Operações matemáticas

```
ADC #$01   ; ADd with Carry
           ; A = A + $01 + carry
           ; if the result is zero, the zero flag will be set

SBC #$80   ; SuBtract with Carry
           ; A = A - $80 - (1 - carry)
           ; if the result is zero, the zero flag will be set

CLC        ; CLear Carry flag in status register
           ; usually this should be done before ADC

SEC        ; SEt Carry flag in status register
           ; usually this should be done before SBC

INC $0100  ; INCrement value at address $0100
           ; if the result is zero, the zero flag will be set

DEC $0001  ; DECrement $0001
           ; if the result is zero, the zero flag will be set

INY        ; INcrement Y register
           ; if the result is zero, the zero flag will be set

INX        ; INcrement X register
           ; if the result is zero, the zero flag will be set

DEY        ; DEcrement Y
           ; if the result is zero, the zero flag will be set

DEX        ; DEcrement X
           ; if the result is zero, the zero flag will be set

ASL A      ; Arithmetic Shift Left
           ; shift all bits one position to the left
           ; this is a multiply by 2
           ; if the result is zero, the zero flag will be set

LSR $6000  ; Logical Shift Right
           ; shift all bits one position to the right
           ; this is a divide by 2
           ; if the result is zero, the zero flag will be set
```

Comparações

```
CMP #$01   ; CoMPare A to the value $01
           ; this actually does a subtract, but does not keep the result
           ; instead you check the status register to check for equal, 
           ; less than, or greater than

CPX $0050  ; ComPare X to the value at address $0050

CPY #$FF   ; ComPare Y to the value $FF
```

Controle de flow

```
JMP $8000  ; JuMP to $8000, continue running code there

BEQ $FF00  ; Branch if EQual, contnue running code there
           ; first you would do a CMP, which clears or sets the zero flag
           ; then the BEQ will check the zero flag
           ; if zero is set (values were equal) the code jumps to $FF00 and runs there
           ; if zero is clear (values not equal) there is no jump, runs next instruction

BNE $FF00  ; Branch if Not Equal - opposite above, jump is made when zero flag is clear
```

### Estrutura de código

#### iNES Header

Armazena informações sobre o jogo. Incluindo mapper, graphics mirroring, PRG/CHR sizes, etc.

```
.inesprg 1   ; 1x 16KB bank of PRG code
.ineschr 1   ; 1x 8KB bank of CHR data
.inesmap 0   ; mapper 0 = NROM, no bank swapping
.inesmir 1   ; background mirroring (ignore for now)
```

#### Banking

Para cada banco, você precisa dizer para o assembler em que endereço de memória ele começa

```
  .bank 0
  .org $C000
;some code here

  .bank 1
  .org $E000
; more code here

  .bank 2
  .org $0000
; graphics here
```

#### Adicionando binários

```
.incbin "mario.chr"
```

#### Vectors

There are three times when the NES processor will interrupt your code and jump to a new location. These vectors, held in PRG ROM tell the processor where to go when that happens. Only the first two will be used in this tutorial.

- **NMI Vector**: Acontece uma vez por frame. Avisa a hora do vBlank e sinaliza disponibilidade de atualizar os gráficos.
- **RESET Vector**: Acontece quando o NES liga, ou quando aperta RESET.
- **IRQ Vector**: É ativado por "mapper chips" ou "audio interrupts" (ignorado neste tutorial).

Todo código deve conter esses 3 vetores.

```
.dw NMI        ;when an NMI happens (once per frame if enabled) the 
               ;processor will jump to the label NMI:
.dw RESET      ;when the processor first turns on or is reset, it will jump
               ;to the label RESET:
.dw 0          ;external interrupt IRQ is not used in this tutorial
```

### Palettes

Existem 2 paleta de cores de 16 bits cada:
- Uma para o background
- Uma para os sprites

A paleta começa no endereço `$3F00` e `$3F10`.

Porta `$2006` da PPU é usada para mexer com as paletas.
- Essa porta precisa ser escrita duas vezes seguidas sempre, uma para o byte alto, e uma para o byte baixo.

```
LDA $2002    ; read PPU status to reset the high/low latch to high
LDA #$3F
STA $2006    ; write the high byte of $3F10 address
LDA #$10
STA $2006    ; write the low byte of $3F10 address
```

Ao "distribuir" as cores da paleta, o NES incrementa automaticamente o index. Então você só precisa se preocupar em setar o endereço inicial mesmo.

Exemplo:

```
LDA #$32   ;code for light blueish
STA $2007  ;write to PPU $3F10
LDA #$14   ;code for pinkish
STA $2007  ;write to PPU $3F11
LDA #$2A   ;code for greenish
STA $2007  ;write to PPU $3F12
LDA #$16   ;code for redish
STA $2007  ;write to PPU $3F13
```

Para armazenar isso de maneira mais prática e direta, use estruturas de `.db`:

```
.db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F  ;background palette data
.db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C  ;sprite palette data
```

E "distribua" ela com um loop assim:

```
  LDX #$00                ; start out at 0
LoadPalettesLoop:
  LDA PaletteData, x      ; load data from address (PaletteData + the value in x)
                          ; 1st time through loop it will load PaletteData+0
                          ; 2nd time through loop it will load PaletteData+1
                          ; 3rd time through loop it will load PaletteData+2
                          ; etc
  STA $2007               ; write to PPU
  INX                     ; X = X + 1
  CPX #$20                ; Compare X to hex $20, decimal 32
  BNE LoadPalettesLoop    ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                          ; if compare was equal to 32, keep going down
```

### Sprites

- Tudo que se move é sprite.
- Sprites são feitos de 8x8 pixels.
- Sprites são criados usando DMA (direct memory access), bruto, literalmente chumba na tela.
- RAM `$0200-02FF` é usada para isso.
- Para transferir, precisa de 2 bytes: low e high.

```
LDA #$00
STA $2003  ; set the low byte (00) of the RAM address
LDA #$02
STA $4014  ; set the high byte (02) of the RAM address, start the transfer
```

- Esse processo de "desenhar" deve ficar na sessão de **NMI** do código!

#### Sprite data

- Cada sprite precisa de 4 bytes para existir:
	- 0: Y position
	- 1: Tile number
	- 2: Attribute
	- 3: X position

Attrs:

```
  76543210
  |||   ||
  |||   ++- Color Palette of sprite.  Choose which set of 4 from the 16 colors to use
  |||
  ||+------ Priority (0: in front of background; 1: behind background)
  |+------- Flip sprite horizontally
  +-------- Flip sprite vertically
```

- Essa distribuição de bytes se repete **64** vezes, para preencher a tela toda.
- Assim como nós "ligamos" o fundo azul da tela na lição anterior, para exibir sprites também é preciso "ligar" eles na porta `$2001` da PPU (bit 4).
- Ligando ele na porta `$2001`, precisa ativar também na porta de controle da PPU `$2000`:

```
  PPUCTRL ($2000)
  76543210
  | ||||||
  | ||||++- Base nametable address
  | ||||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
  | |||+--- VRAM address increment per CPU read/write of PPUDATA
  | |||     (0: increment by 1, going across; 1: increment by 32, going down)
  | ||+---- Sprite pattern table address for 8x8 sprites (0: $0000; 1: $1000)
  | |+----- Background pattern table address (0: $0000; 1: $1000)
  | +------ Sprite size (0: 8x8; 1: 8x16)
  |
  +-------- Generate an NMI at the start of the
            vertical blanking interval vblank (0: off; 1: on)
```

Exemplo de código adicionando um sprite na tela e ativando o necessário para ele aparecer:

```
LDA #$80
STA $0200        ;put sprite 0 in center ($80) of screen vertically
STA $0203        ;put sprite 0 in center ($80) of screen horizontally
LDA #$00
STA $0201        ;tile number = 0
STA $0202        ;color palette = 0, no flipping

LDA #%10000000   ; enable NMI, sprites from Pattern Table 0
STA $2000

LDA #%00010000   ; no intensify (black background), enable sprites
STA $2001
```




------------------------------------------------------------------------------------------
## Anotações vídeo tutorial

Baseadas neste vídeo: https://www.youtube.com/watch?v=V5uWqdK92i0

- Compilador: CC65
- Ferramenta chamada YY-CHR usada para visualizar os sprites
  - Exclusivo pra Windows :(
- Fluxo de compilação aparentemente é igual o do GB (ASM -> .O -> .NES)
- FCEUX é o emulador utilizado

## Entendendo o código assembly

5 sessões:
- HEADER
- ZEROPAGE
- STARTUP
- VECTORS
- CHARS

## Compilando

```sh
ca65 cart.s -o cart.o -t nes
ld65 cart.o -o cart.nes -t nes
```

## Interrupção

Parei este vídeo tutorial no meio, pois o cara estava ensinando tirando muito código do cu, sem explicar o motivo. Não gostei.
