#!/bin/bash

# Convert font
rgbgfx assets/text-font.png -u -c "#FFFFFF,#cbcbcb,#414141,#000000;" -o text-font.2bpp && \

# Convert spaceship sprite
rgbgfx assets/spaceship.png -u -o spaceship.2bpp && \

# Convert background sprite
rgbgfx assets/background.png -u -c "#9bbc0f,#8bac0f,#306230,#0f380f;" -o background.2bpp -t background.tilemap && \

# Compile game
rgbasm -o main.o main.asm && \
rgblink -o rails.gb main.o && \
rgbfix -v -p 0xFF rails.gb && \
rgblink -n rails.sym main.o && \

# Clean trash
rm main.o

# Copy rom to windows folder
if [ "$1" == "--win" ]; then
    cp rails.gb /mnt/c/Users/renan/Downloads/
    cp rails.sym /mnt/c/Users/renan/Downloads/
fi

echo "Done!"
