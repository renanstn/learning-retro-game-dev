# Tiles and Tilemap

## Definições

- Screen: 160 x 144px
- Tile: 8 x 8px

## Tiles

> Carregar no endereço `$9000`

Cada `Tile` pode ser definido por um `dw `, e os valores seguem a paleta de
cores: - `0`: Branco - `1`: Cinza - `2`: Cinza escuro - `3`: Preto

```asm
dw `33333333
```

## Tilemap

> Caregar no endereço de VRAM `$9800`

O `Tilemap` deve obrigatoriamente ser uma linha de - **20** bytes de largura - **18** bytes de altura - Definidos por `db`

## Scripts úteis

### Conferindo as dimensões de um arquivo

```sh
identify input.png
```

### Reduzindo a quantidade de cores de uma imagem:

```sh
sudo apt install imagemagick
```

```sh
convert input.png -colors 4 output.png
```

### Completado a imagem para ocupar a tela toda

```sh
convert input.png -background white -gravity NorthWest -extent 160x144 output.png
```

### Gerando os tiles + tilemap

> Precisa ser uma imagem de 256x256 para

```sh
rgbgfx -u in.png -o out.2bpp -t out.tilemap
```
