#!/bin/bash

# Convert sprites to 2bpp format
../tools/rgbds/rgbgfx -o test.2bpp sprites/knight-4.png && \

# Compile game
rgbasm -o main.o main.asm && \
rgblink -o hollow-knight.gb main.o && \
rgbfix -v -p 0xFF hollow-knight.gb && \
rgblink -n hollow-knight.sym main.o && \
rm main.o && \

# Run game
java -jar ../tools/Emulicious/Emulicious.jar hollow-knight.gb
