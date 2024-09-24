# Tiles and Tilemap

## Definições

- Screen: 160 x 144px (20 x 18 map positions)
- Total: 256 x 256px
- Tile: 8 x 8px
- Scroll X (0 ˜ 255)
- Scroll Y (0 ˜ 255)
- Window X (0 ˜ 255)
- Window Y (0 ˜ 255)

## Tiles

> Carregar no endereço `$9000`

Cada `Tile` pode ser definido por um `dw`, e os valores seguem a paleta de cores:

- `0`: Branco
- `1`: Cinza
- `2`: Cinza escuro
- `3`: Preto

```asm
dw `32201223
```

## Tilemap

> Caregar no endereço de VRAM `$9800`

O `Tilemap` deve obrigatoriamente ser um bloco de

- **20** bytes de largura
- **18** bytes de altura
- Definidos por `db`

## Objetos

Existe um espaço na memória exclusivo para você criar os objetos do seu jogo.

Objetos possuem 4 bytes, sendo eles:

| Ordem | Valor      |
|-------|------------|
| 0     | Y position |
| 1     | X Position |
| 2     | Tile ID    |
| 3     | Attributes |

### Espaços de vRAM para objetos

- O primeiro quadrante `$8000+` é exclusivo para objetos
- O segundo quadrante pode ser objetos ou BG
- O terceiro quadrante é apenas BG

## Scripts úteis

Todos os scripts utilizam a ferramenta de CLI [ImageMacick](https://imagemagick.org/index.php).

```sh
sudo apt install imagemagick
```

### Conferindo as dimensões de um arquivo

```sh
identify input.png
```

### Reduzindo a quantidade de cores de uma imagem:

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

## Referências absurdas de boas

- How GameBoy Graphics Work Part 1: https://www.youtube.com/watch?v=txkHN6izK2Y
- How GameBoy Graphics Work Part 2: https://www.youtube.com/watch?v=_h5TXh20_fQ
- How GameBoy Graphics Work Part 3: https://www.youtube.com/watch?v=SK7XT0DWqtE
- How GameBoy Graphics Work Part 4: https://www.youtube.com/watch?v=8TVgN16DrEU
