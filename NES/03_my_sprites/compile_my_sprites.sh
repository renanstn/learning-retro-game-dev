#!/bin/sh

ca65 my_sprites.s -o my_sprites.o -t nes && \
ld65 my_sprites.o -o my_sprites.nes -t nes && \
rm my_sprites.o && \
fceux my_sprites.nes
