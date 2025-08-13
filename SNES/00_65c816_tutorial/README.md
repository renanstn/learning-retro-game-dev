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

- TODO
