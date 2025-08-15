# Wesley Guide

Anotações referentes a este guia encontrado:

https://blog.wesleyac.com/posts/snes-dev-1-getting-started

## Setup

Ferramentas necessárias:

- Um assembler e linker para 65816: cc65 (o mesmo do NES).
- Um emulador de SNES: Recomendado o Mesen-S: https://mesen.ca/ pois possui um bom debugger.

## 1. Código

https://github.com/WesleyAC/snes-dev/tree/main/part1/src

### Arquivos

- registers.inc: Cria alias para todos os valores de registradores.
- macros.inc: Cria macros para alterar entre os modos 8 e 16 bits, por preguiça de fazer um sep #$20
- init.asm: Código de inicialização, ele é chamado logo no start via `.include "init.asm"`
- main.asm: Main é main!
- header.asm: O bom e velho header que toda rom precisa.
- lorom.cfg: Um arquivo `cfg` é requerido pelo compiler para compilar para SNES.

## Desafios da parte 1

- Mudar a cor de fundo de vermelho para azul:
	- Se $001f = %0000000000011111 (bbbbbgggggrrrrr) = vermelho, então
	- 1111100000000000 = Azul
- Corrigir o init.asm
	-
