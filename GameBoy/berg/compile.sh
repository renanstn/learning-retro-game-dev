rgbasm -o main.o main.asm && \
rgblink -o berg.gb main.o && \
rgbfix -v -p 0xFF berg.gb

