#!/bin/bash

# Compila o jogo.
# Joga uma cópia da ROM na pasta Download caso esteja no windows (wsl)
# para facilitar a abertura.

rgbasm -o main.o main.asm && \
rgblink -o berg.gb main.o && \
rgbfix -v -p 0xFF berg.gb

if [ "$1" == "--win" ]; then
    cp berg.gb /mnt/c/Users/renan/Downloads/
fi
