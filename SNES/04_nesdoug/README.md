# Nesdoug

Anotações referentes a este guia encontrado:

https://nesdoug.com/2020/03/19/snes-projects/

## Part 01: Hello world!

> https://nesdoug.com/2020/05/14/snes-example-1/

Hello world com tela vermelha, funcionando!

## Part 02: Direct Memory Access (DMA)

> https://nesdoug.com/2020/05/16/dma-palette/

Na etapa de criar a palette, poderíamos fazer um loop para mover byte a byte
para o CGDATA, porém, existe uma forma mais rápida, usando DMA.

O main use do DMA é copiar dados para:
- `$2104`: OAM data
- `$2118`: VRAM data
- `$2122`: CG data

> DMA precisa acontecer durante o v-blank!

Existem 8 channels que podemos usar.

### Registradores de DMA:

- `$4300` to set up the transfer mode.
- `$4301` is the destination register $21xx. So, $04 = $2104. $18 = $2118. Etc.
- `$4302` is the source address, low byte
- `$4303` is the source address, high byte
- `$4304` is the source address, bank byte
- `$4305` is the number of bytes, low byte
- `$4306` is the number of bytes, high byte

Then, for channel `0`, you write `#1` to `$420b` to start the transfer. This locks up the CPU until the transfer is complete.

> Only one DMA is performed at a time, and if you activate multiple channels
> with the same 420b write, they are performed sequentially, one at a time.

Outros exemplos de DMA transfer: https://github.com/nesdoug/SNES_02/blob/master/DMA_Examples.txt

## Part 03: Backgrounds

> https://nesdoug.com/2020/05/16/backgrounds/

> A imagem que formará o background para essa lição deverá ter **256x256** de dimensão.

Comando usado para converter a imagem para o formato do SNES

```shell
.\superfamiconv.exe -v --mode snes --in-image pica-3.png --out-palette snes.palette --out-tiles snes.tiles --out-map snes.map --out-tiles-image tiles.png
```

Funcionando!

## Part 04: Layers

Ordem de layers do `mode 1`:

```
(top)
Sprites with priority 3
BG1 tiles with priority 1
BG2 tiles with priority 1
Sprites with priority 2
BG1 tiles with priority 0
BG2 tiles with priority 0
Sprites with priority 1
BG3 tiles with priority 1
Sprites with priority 0
BG3 tiles with priority 0
(bottom)
```

> Lembrando que, tudo na cor `#0` em um tile, será transparente!

Converti uma foto minha com o comando:

```shell
.\superfamiconv.exe -v --mode snes --in-image eu-quantized.png --out-palette snes.palette --out-tiles snes.tiles --out-map snes.map --out-tiles-image tiles.png
```

Ferramenta útil: https://lospec.com/palette-quantizer/

Utilizei a foto em um dos layers, funcionou!

Para a segunda imagem, o fundo dela precisa ser transparente.
A cor de fundo atual é `#e1f2e9`.

Converti a foto indicando a transparência com o comando:

```shell
.\superfamiconv.exe -v --mode snes --in-image fodase-quantized-full-size.png --out-palette snes_02.palette --out-tiles snes_02.tiles --out-map snes_02.map --out-tiles-image tiles2.png --out-scaled-image image2.png
```

Detalhe interessante, o material bruto importado excedeu o espaço do `RODATA1`.
Então precisei colocá-los no `RODATA2`.

O exemplo já está funcional, mas aqui eu fiz uma cagada que vale nota:
- Eu carreguei o que deveria ser o BACKGROUND (minha foto) no layer `BG1`
- Eu carreguei o que deveria ser o FOREGOUND (a imagem com transparência) no layer `BG2`
> Isso deveria ser feito invertido. Pois o BG2 fica sobre o BG1.

Para arrumar essa cagada, eu mexi nessa seção:

```asm
lda #$04
sta BG12NBA

lda #$68
sta BG1SC

lda #$60
sta BG2SC
```

Esses registradores são o mapa da memória gráfica do SNES para backgrounds.

- `BG12NBA` -> `Background 1 and 2` -> Indica onde estão os respectivos backgrounds
  - Formato: `BBBB AAAA`
    - `AAAA` -> Tiles do BG1
    - `BBBB` -> Tiles do BG2
  - Eu coloquei o valor `$04` -> `%01000000` -> `0100 0000`
    - Cada unidade vale 1000 bytes
    - Logo, eu indiquei que o BG1 começa em `$0000`, e o BG2 começa em `$4000`
- `BG1SC` e `BG1SC` -> `Background 1 and 2 Screen Configuration` -> Endereço do tilemap
  - Formato: `AAAAAASS`
    - `AAAAAA` -> Endereço
    - `SS` -> Tamanho

A paleta de cores do BG2 ficou toda fudida, preciso gerar o map do BG2 apontando para a mesma paleta usada no BG1:

```shell
.\superfamiconv.exe tiles -v --mode snes -i "fodase-quantized-full-size-right-colors.png" --in-palette "snes_01.pal" -o snes_02.chr
```
