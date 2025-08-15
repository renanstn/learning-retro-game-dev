#!/bin/sh

ca65 --cpu 65816 -o background.o part_01.asm && \
ld65 -C lorom.cfg background.o -o background.smc && \
flatpak run io.github.xyproto.zsnes background.smc

# No meu ThinkPad velho foi necessário usar Flatpack
# para conseguir rodar um emulador.
# https://flathub.org/apps/io.github.xyproto.zsnes
