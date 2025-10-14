#!/bin/bash

# Convert sprites to 2bpp format
../tools/rgbds/rgbgfx -o test.2bpp sprites/knight-5.png && \

# Compile game
../tools/rgbds/rgbasm -o main.o main.asm && \
../tools/rgbds/rgblink -o hollow-knight.gb main.o && \
../tools/rgbds/rgbfix -v -p 0xFF hollow-knight.gb && \
../tools/rgbds/rgblink -n hollow-knight.sym main.o && \
rm main.o && \

# Run game
java -jar ../tools/Emulicious/Emulicious.jar hollow-knight.gb
