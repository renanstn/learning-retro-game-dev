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

Converter a imagem para uma paleta de 4 cores

```sh
convert berg-48x64.png -colors 4 berg-4-colors.png
```

Converter a imagem para uma paleta de 4 cores regulando brilho e contraste

```sh
convert berg-48x64.png -colors 4 -brightness-contrast 50x0 berg-4-colors.png
```

### Completado a imagem para ocupar a tela toda

```sh
convert berg-4-colors.png -background white -gravity NorthWest -extent 256x256 berg-screen.png
```

### Gerando os tiles + tilemap

> Precisa ser uma imagem de **256x256**!!!

```sh
rgbgfx -u berg-screen.png -o berg.2bpp -t berg.tilemap
```

### Gerar tilemap das letras

```sh
rgbgfx text-font-inverted.png -c "#FFFFFF,#cbcbcb,#414141,#000000;" -o letters.2bpp
```
