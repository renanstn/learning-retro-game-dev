# SNES

*Todos os estudos feitos neste repositório até agora foi para chegar até aqui ❤️*

## Guias encontrados

- https://ersanio.gitbook.io/assembly-for-the-snes
- https://blog.wesleyac.com/posts/snes-dev-1-getting-started
- https://www.chibiakumas.com/6502/snes.php
- https://georgjz.github.io/snesaa01/
- https://wiki.superfamicom.org/asm-tutorial-part-1
- https://nesdoug.com/2020/05/14/snes-example-1/

## Referências técnicas

- https://wiki.superfamicom.org/65816-reference
- https://bin.smwcentral.net/u/4842/regs.txt
- https://problemkaputt.de/fullsnes.htm
- http://nuclear.mutantstargoat.com/articles/snes_notes/refs/snes_dev_manual1.pdf (o manual oficial da Nintendo)
- https://wiki.superfamicom.org/
- https://ersanio.gitbook.io/assembly-for-the-snes/

## Referências criativas

- https://www.youtube.com/watch?v=EBLze4PXX2U

## Ferramentas

- Conversor de sprites: https://github.com/Optiroc/SuperFamiconv
- Fazer músicas: https://github.com/nathancassano/snesgss
- Tutorial Furnace: https://www.youtube.com/watch?v=Q37XuOLz0jw

## Compilando e gerando uma ROM

```
ca65 --cpu 65816 -o output.o game.asm && \
ld65 -C lorom.cfg output.o -o game.smc
```
