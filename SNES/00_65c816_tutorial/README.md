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

- TODO
