# Flows

## Criando sprites do zero

- Escolhi uma spitesheet no *The Spriters Resource*
- Recortei no Aseprite, alterei o *color mode* para **indexed colors**
- No NEXXT studio: File -> import -> import image
- File -> patterns (.chr) -> save all CHR banks

Com isso eu já consegui gerar um arquivo .chr funcional, eu abri ele no YY-CHR para conferir.

## Convert JPG to NES BG

Testar isso:

```
convert input.jpg -resize 256x240! output.png
```

O ! força exatamente o tamanho, ignorando a proporção. Se você quiser manter proporção, pode omitir o !.

Limite a paleta

```
convert input.png +dither -remap nes_palette.png output.png
```

- +dither desativa dithering (se você quiser controlar os pixels exatamente).
- -remap nes_palette.png força a imagem a usar apenas as cores definidas na paleta.

Reduza as cores

```
convert input.png -colors 4 output_tile.png
```

Reconte os tiles

```
convert input.png -crop 8x8 +repage tile_%03d.png
```
