#!/bin/sh

../tools/cc65_bin/ca65 --cpu 65816 -o output.o main.asm && \
../tools/cc65_bin/ld65 -C smc.cfg output.o -o game.smc && \
rm output.o && \
../tools/Snes9x-1.63-x86_64.AppImage game.smc
