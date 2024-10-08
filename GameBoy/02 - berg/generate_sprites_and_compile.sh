#!/bin/bash

convert berg-pixel.png -colors 4 -brightness-contrast 10x70 berg-4-colors.png && \
convert berg-4-colors.png -background white -gravity NorthWest -extent 256x256 berg-screen.png && \
rgbgfx -u berg-screen.png -o berg.2bpp -t berg.tilemap && \
rgbasm -o main.o main.asm && \
rgblink -o berg.gb main.o && \
rgbfix -v -p 0xFF berg.gb
