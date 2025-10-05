rgbasm -o hello-world.o hello-world.asm && \
rgblink -o hello-world.gb hello-world.o && \
rgbfix -v -p 0xFF hello-world.gb

java -jar ../tools/Emulicious/Emulicious.jar hello-world.gb
