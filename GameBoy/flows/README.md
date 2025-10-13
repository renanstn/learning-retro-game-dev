# Flows

## Criando meus próprios sprites

- Criar o sprite respeitando:
  - As proporções de pixel do GB (8x8)
  - A paleta de cores (4 cores)
  - Pode usar um PNG com transparência
- Converta esse sprite em formato `.2bpp` usando a ferramenta `rgbfx`
  - `rgbgfx -o test.2bpp hollow-kinght-1.png`
- Inclua o arquivo `.2bpp` no jogo com `INCBIN`
```asm
Tiles:
	INCBIN "test.2bpp"
TilesEnd:

```
- Já deverá existir uma rotina de load que carrega os tiles, algo assim:
```asm
	; Copy the tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles
```
