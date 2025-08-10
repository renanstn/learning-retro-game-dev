#!/bin/sh

ca65 04_pong.s -o pong.o -t nes && \
ld65 pong.o -o pong.nes -t nes
