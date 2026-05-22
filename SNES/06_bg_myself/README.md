# BG

Aquele teste básico que eu sempre faço quando aprendo qualquer emulador, de fazer aparecer uma foto de alguém na tela.

No caso do SNES usaremos o `BG MODE 1`, e colocaremos uma foto minha no BG1.

## Pré requisito

Ter o Image Magick instalado

https://imagemagick.org/#gsc.tab=0

## Gerando os assets

Execute o `generate_assets.bat`

Isso irá gerar os arquivos `.chr`, `.pal` e `.map` que importaremos no código assembly do SNES.

## Gerando a ROM

Execute o `compile.bat`

O jogo será compilado e rodará.
