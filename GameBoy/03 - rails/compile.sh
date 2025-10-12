#!/bin/bash

# Compila o jogo.
# Joga uma cópia da ROM na pasta Download caso esteja no windows (wsl)
# para facilitar a abertura.

rgbasm -o main.o main.asm && \
rgblink -o rails.gb main.o && \
rgbfix -v -p 0xFF rails.gb
rm main.o && \

if [ "$1" == "--win" ]; then
    cp rails.gb /mnt/c/Users/renan/Downloads/
fi

java -jar ../tools/Emulicious/Emulicious.jar rails.gb
