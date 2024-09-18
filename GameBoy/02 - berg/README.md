# Berg

## Descrição

Este repositório foi um desafio pessoal simples.

Se eu realmente aprendi o **básico** sobre sprites/tilemap em GB, eu serei capaz
de fazer aparecer a cara do Berg fumando 2 cigarros na tela de um Game Boy.

Deu certo! Consegui!

Adicionei um texto na tela como bônus.

## Procedimentos

- Reduzir a imagem original para um tamanho inferior a `256x256`
- Reduzir a imagem original a uma paleta de apenas 4 cores
- Usar a ferramenta `rgbgfx` para gerar os arquivos `.2bpp` dos sprites e o
  arquivo `.tilemap`
- De posse desses ambos arquivos binários, incluí-los no código fonte com o
  comando `INCBIN`
