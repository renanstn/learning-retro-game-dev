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

Aqui eu fiz tudo usando aseprite e a ferramente M1TE.

- Primeiro eu criei uma palette no aseprite, color mode -> indexed. Exportei
- Depois eu criei um sprite, apliquei a palette, color mode -> indexed. Exportei
- Depois eu criei outro sprite, apliquei a palette, color mode -> indexed. Exportei
- Carreguei a palette no M1TE usando a imagem que eu exportei
- Carreguei os tiles do sprite 1 no M1TE, com a palette selecionada
- Coloquei o "cursor" dos tiles logo adiante, e carreguei o sprite 2 no M1TE
- Pintei o desenho no map, salvei
- Mudei o BG para #2, pintei o outro sprite, salvei
- Exportei a palette
- Exportei os tiles
- Deu certo.
