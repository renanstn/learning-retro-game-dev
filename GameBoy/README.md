# Game Boy

> Mais anotações sobre temas específicos foram salvos na pasta [docs](docs/)

Fonte: https://gbdev.io/gb-asm-tutorial/index.html

CPU code reference: https://rgbds.gbdev.io/docs/v0.8.0/gbz80.7

## Pré-requisitos

### O compilador

O compilador utilizado é o **RGBDS**. 
Ele já vem com várias ferramentas úteis como o RGBFIX para validar as roms e o RGBGFX para conversão de sprites.

- https://rgbds.gbdev.io/install
- https://github.com/gbdev/rgbds

### O emulador

O emulador utilizado é o Emulicious, pois vem com um bom debugger.

- Baixei o emulador [Emulicious](https://emulicious.net/downloads/)
- Instalei o `default-jre` (java) para conseguir executar o emulador

```shell
sudo apt install default-jre
# Abrir o emulador
java -jar Emulicious.jar
# Abrir o emulador passando o path da rom para maior praticidade
java -jar Emulicious.jar /home/renan/GitHub/learning-retro-game-dev/GameBoy/unbricked/unbricked.gb
```

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

- Abri o arquivo gerado pelo compilador e **funcionou** :D

> In RGBDS assembly, the hexadecimal prefix is `$`, and the binary prefix is `%`.

- ROM: Memória que não pode ser escrita.
- RAM: Memória que pode ser escrita.
- Chaves `[]` são usadas para referenciar **endereços**.

Gerando um sym da rom:

```shell
rgblink -n hello-world.sym hello-world.o
```

## Armazenamento de tiles

### Referências

- https://www.youtube.com/watch?v=txkHN6izK2Y
- https://www.huderlem.com/demos/gameboy2bpp.html

- Cada tile é composto de 8x8 pixels (64 pixels por tile) (16 bytes)
- Cada pixel usa um valor de 0 a 3 para indicar sua paleta de cor (branco, cinza, cinza escuro, preto)
- 2 bits for pixel (2bpp)
- Esses 2 bits por pixel são divididos no armazenamento
  - Um grupo é criado com os valores da "esquerda"
  - Um grupo é criado com os valores da "direita"
  - Ai fica armazenado primeiro os da direita, depois os da esquerda

## Part II

### Objects

- Objetos se movem em cima do background.
- Objetos são compostos de um ou dois tiles, ou seja
  - 8x8
  - 8x16
- Objetos são armazenados na `OAM` (object attribute memory)
- Objetos consistem em:
  - Posição na tela
  - Tile ID
  - Atributos
- Armazenados em 4 bytes
  - Um para a posição Y
  - Um para a posição X
  - Um para o tile ID
  - Um para os atributos
- A OAM tem 160 bytes, então logo, cabem 40 objetos ali (160/4=40)

> Os bytes que armazenam as coordenadas Y e X na verdade **não se referem a
> coordenada exata na tela**, o valor X na verdade é _X-8_, e o valor Y é _Y-16_.
