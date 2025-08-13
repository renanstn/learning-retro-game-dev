# 65c816 Crash Course

https://ersanio.gitbook.io/assembly-for-the-snes

## Memória

- A Memória vai de `$000000` a `$FFFFFF`
- Mas somente de `$000000` a `$7FFFFF` é usado normalmente

| Formato de endereço:  `$BBHHDD`

- `BB` is the "bank byte" of the address
- `HH` is the "high byte" of the address
- `DD` is the "low byte" of the address

| Addresses can be written in 3 ways: `$BBHHDD`, `$HHDD` and `$DD`, such as `$7E0003`, `$0003` and `$03`.

### ROM

- Já manjo

### RAM

- Já manjo

### SRAM

É a área dividida em blocos de 32kb em:

- $700000-$707FFF
- $710000-$717FFF
- $720000-$727FFF
- $730000-$737FFF

Essa memória **não é apagada** ao desligar o console, é pra salvar jogos.

## Registradores

- [A] Accumulator: Usado para matemática em geral.
	- Pode armazenar valores de 8 ou 16 bits
	- As vezes, pode ser referido como `B` ou `C`
		- B: high byte do acumulador
		- C: low byte do acumulador
- [X][Y] Indexers: Servem para indexação.
	- Pode armazenar valores de 8 ou 16 bits
- Direct Page: É um registrador de 16 bits usado para direct page addressing mode.
- Stack Pointer: Registrador de 16 bits que armazena o ponteiro para a stack na RAM.
- Processor Status: Armazena as flags de configuração do processador.
- Data Bank: Armazena o atual endereço do data bank.
- Program Bank: Armazena o banco da função atual sendo executada.
- Program Counter: Armazena o high e low byte do endereço onde a instrução atual está sendo executada.

## Little-endian!!!

Valores são sempre armazenados na memória em "little endian"!

- O valor `$1234` fica salvo como `$34 $12`!

## Glossário

- Byte: 8-bit value
- Word: 16-bit value
- Long: 24-bit value

## Loading and Storing values

O mesmo de sempre, como visto no NES

```
LDA #$03           ; A = $03
STA $7E0001
```

| O `#` antes do valor indica que estamos armazenando em `A` o literal valor $03, e não o endereço de memória.

### STZ

Esse comando é novo! Significa "Store zero to memory".

```
STZ $01            ; $7E0001 = $00. The A register is unaffected.
```

## 8-bit and 16-bit mode

Trocando de modos:

| Operation  | Explanation                          |
|------------|--------------------------------------|
| REP #$10   | Sets X and Y to 16-bit mode           |
| REP #$20   | Sets A to 16-bit mode                 |
| REP #$30   | Sets A, X and Y to 16-bit mode        |
| SEP #$10   | Sets X and Y to 8-bit mode            |
| SEP #$20   | Sets A to 8-bit mode                  |
| SEP #$30   | Sets A, X and Y to 8-bit mode         |

Exemplo de uso

```
REP #$20
LDA #$0001
STA $7E0000
SEP #$20
```

Este código:

- Seta o acumulador para o modo 16 bits
- Salva o valor #$0001 no endereço $7E0000
- Sai do modo 16 bits

## Comparações, branching e labels

### Comparações

- Já sei como funciona

### Branches

- O opcode do JUMP só aceita valores de -128 a 127! Isso é importante!

### Labels

- Já sei como funciona

### CMP

- Compara algo com o que está em `A`.

### BEQ e BNE

- Branch If Equals.
- Branch IF Not Equals.

Já sei como usar.

### Comparando com endereços

É possível comparar algo com o valor armazenado em um endereço:

```
LDA $00            ; Load $7E0000's value into A
CMP $02            ; Compare A with $7E0002
BEQ Equal          ; Branch if equal
```

### CPX e CPY

- Compara com X e Y. Já sei usar.

### BMI e BPL

- Esses são novos!
- BMI: **Branch if minus**: Branches if the last operation resulted in a negative value (thus, negative flag set).
- BPL: **Branch if plus**: Branches if the last operation resulted in a positive value (thus, negative flag clear).

### BCS e BCC

- BCS: **Branch if carry set**: Basically branches if the loaded value is greater than or equal to the compared value (thus, carry flag set).
- BCC: **Branch if carry clear**: Basically branches if the loaded value is less than the compared value (thus, carry flag clear).

### BVS e BVC

- Esses são novos!
- BVS: **Branch if overflow set**: Branches if the comparison causes a mathematical overflow (thus, overflow flag set).
- BVC: **Branch if overflow clear**: Branches if the comparison doesn't cause a mathematical overflow (thus, overflow flag clear).

### BRA e BRL

- Esses são novos!
- BRA: **Branch always**
- BRL: **Branck long**: Always branches, but with greater reach (para endereços muito distantes).

## Jumping to subroutines

Já estou familiarizado, mas segue exemplo:

```
LDA #$01
STA $01
JSR Label1         ; Execute the "subroutine" located at Label1 (current bank)
LDA #$03           ; The RTS in Label1 will return to this line
STA $00
RTS

Label1:
LDA #$02
STA $02
RTS
```

| Apenas fique esperto pois no SNES existem os modos "long" (Jump Subroutine Longe / Return from Subroutine Long)!

## Tables and indexing

Tipos de dados usados em tables:

| Instruction | Full name      | Explanation                                                 |
|-------------|----------------|-------------------------------------------------------------|
| **db**      | direct byte    | A value denoting a byte (8-bit value, e.g. $XX)              |
| **dw**      | direct word    | A value denoting a word (16-bit value, e.g. $XXXX)           |
| **dl**      | direct long    | A value denoting a long (24-bit value, e.g. $XXXXXX)         |
| **dd**      | direct double  | A value denoting a double (32-bit value, e.g. $XXXXXXXX)     |

Exemplo de definição:

```
ValuesTableExample: db $11,$86,$91,$38,$22
```

## Stack

É possível fazer push dos valores em A, X e Y na stack com os comandos:

- PHA
- PHX
- PHY

Da mesma forma, da pra fazer pull com:

- PLA
- PLX
- PLY

Exemplo de uso:

- Imagine que o registrador X **precisa** guardar o valor $19, mas você precisa usar o registrador X para outra coisa:

```
                   ; Imagine X has the value $19 in the stack
PHX                ; Push X ($19) onto stack. Result: Stack 1st value = $19
LDX $91            ; Load the value in address $7E0091 into X
LDA $1000,x        ; \ X is now modified, and we use it to index RAM
STA $0100          ; /
PLX                ; Restore X. X is now $19 again
```

Tem mais códigos de pull/push, confere a documentação qualquer coisa.

## Copiando dados

O 65c816 tem 2 opcodes destinados a mover grandes blocos de dados de um local para outro:

- MVN: Move block negative: Move no sentido ->
- MVP: Move block positive: Move no sentido <-

É recomendado deixar os registradores todos em modo 16-bit ao fazer MV, e preservar o data bank (não entendi ainda o porque) assim:

```
PHB                ; Preserve data bank
REP #$30           ; 16-bit AXY
                   ; ← Move instructions are located here
SEP #$30           ; 8-bit AXY
PLB                ; Recover data bank
```

### MVN

Ao fazer MVN, todos os 3 registradores principais tem um propósito diferente:

- A: Specifies the amount of bytes to transfer, plus 1
- X: Specifies the high and low bytes of the data source memory address
- Y: Specifies the high and low bytes of the destination memory address

| The A register is "plus 1". This means that if you want to move 4 bytes of data, you load $0003, as this means $0003+1, thus 4 bytes.

MVN pode ser escrito de duas formas:

```
MVN $xxyy
; or
MVN $yy, $xx
```

Where `xx` is the source bank, and `yy` is the destination bank.


Durante a execução do MVN, vai acontecendo isso com os registradores:

- A: Decreases by 1
- X: Increases by 1
- Y: Increases by 1
- Data bank: Is set to the bank of the destination address

Exemplo de uso:

```
PHB                ; Preserve data bank
REP #$30           ; 16-bit AXY
LDA #$0004         ; \
LDX #$8908         ;  |
LDY #$A000         ;  | Move 5 bytes of data from $1F8908 to $7FA000
MVN $7F, $1F       ; /
SEP #$30           ; 8-bit AXY
PLB                ; Recover data bank
```

### MVP

Segue as mesmas regras do MVN, exceto aqui:

- A: Decreases by 1
- X: Decreases by 1
- Y: Decreases by 1
- Data bank: Is set to the bank of the destination address

Exemplo:

```
PHB                ; Preserve data bank
REP #$30           ; 16-bit AXY
LDA #$0004         ; \
LDX #$8908         ;  |
LDY #$A000         ;  | Move 5 bytes of data from ($1F8908-$0004) to ($7FA000-$0004)
MVP $7F, $1F       ; /
SEP #$30           ; 8-bit AXY
PLB                ; Recover data bank
```

### Edge cases

- When you set the A register to $0000, it means you will move 1 byte.

### Easy notation

Você pode usar labels como parameters:

```
PHB
REP #$30
LDA.w #SomeTable_end-SomeTable-$01
LDX.w #SomeTable
LDY #$A000
MVN $7F, SomeTable>>16
SEP #$30
PLB
RTS

SomeTable: db $00,$01,$02,$03,$04
.end
```

```
PHB
REP #$30
LDA.w #SomeTable_end-SomeTable-$01
LDX.w #SomeTable+SomeTable_end-SomeTable-$01
LDY.w #$A000+SomeTable_end-SomeTable-$01
MVP $7F, SomeTable>>16
SEP #$30
PLB
RTS

SomeTable: db $00,$01,$02,$03,$04
.end
```

## Flags do Processador

- TODO
