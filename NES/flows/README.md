# Flows

## Criando meus próprios sprites

- Desenhar o sprite no Aseprite, usando "color mode: indexed"
- O sprite só pode ter 3 cores (a quarta cor é usada para transparência)
- Importar o sprite como tilemap no Nexxt studio
- Exportar o tilemap como um CHR de 8 bytes

## Usando sprites prontos

- Escolhi uma spitesheet no *The Spriters Resource*
- Recortei no Aseprite, alterei o *color mode* para **indexed colors**
- No NEXXT studio: File -> import -> import image
- File -> patterns (.chr) -> save 8k

O chr, no meu caso, precisava ter 8kb de tamanho, pois isso estava de alguma forma pré-definida no código e eu ainda não aprendi a mudar.

Com isso eu já consegui gerar um arquivo .chr funcional, eu abri ele no YY-CHR para conferir.

Consegui também gerar uma ROM válida, importando o CHR, e vendo os sprites na PPU viewer.
