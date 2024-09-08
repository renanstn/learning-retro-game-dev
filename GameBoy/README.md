# Game Boy

Fonte: https://gbdev.io/gb-asm-tutorial/index.html

CPU code reference: https://rgbds.gbdev.io/docs/v0.8.0/gbz80.7

## Pré-requisitos

### O compilador

- https://rgbds.gbdev.io/install
- https://github.com/gbdev/rgbds

## Hello world

Fonte: https://gbdev.io/gb-asm-tutorial/part1/hello_world.html

Criei um arquivo `.asm` e um arquivo `.inc`.

Compilei tudo com:

```shell
rgbasm -o hello-world.o hello-world.asm
rgblink -o hello-world.gb hello-world.o
rgbfix -v -p 0xFF hello-world.gb
```

Fluxo de compilação:

> Source code → rgbasm → Object files → rgblink → “Raw” ROM → rgbfix → “Fixed” ROM. Good.

- Baixei o emulador [Emulicious](https://emulicious.net/downloads/)
- Instalei o `default-jre` para conseguir executar o emulador

```shell
sudo apt install default-jre
java -jar Emulicious.jar
```

- Abri o arquivo gerado pelo compilador e **funcionou** :D

In RGBDS assembly, the hexadecimal prefix is `$`, and the binary prefix is `%`.

ROM: Memória que não pode ser escrita.
RAM: Memória que pode ser escrita.

Chaves são usadas para referencias **endereços**.

Gerando um sym da rom:

```shell
rgblink -n hello-world.sym hello-world.o
```

> On GB, tiles are always 8 by 8 pixels.

> Game Boy palettes are 4 colors large.

## Armazenamento de tiles

### Referências: 

- https://www.youtube.com/watch?v=txkHN6izK2Y
- https://www.huderlem.com/demos/gameboy2bpp.html

- Cada tile é composto de 8x8 pixels (64 pixels por tile) (16 bytes)
- Cada pixel usa um valor de 0 a 3 para indicar sua paleta de cor (branco, cinza, cinza escuro, preto)
- 2 bits for pixel (2bpp)
- Esses 2 bits por pixel são divididos no armazenamento
	- Um grupo é criado com os valores da "esquerda"
	- Um grupo é criado com os valores da "direita"
	- Ai fica armazenado primeiro os da direita, depois os da esquerda
