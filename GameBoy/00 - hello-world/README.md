## Buildando o hello world

O ciclo de build de uma rom de GB é sempre o mesmo:

1. RGBASM: Compila o código e o transforma em um object file `.o` intermediário.
2. RGBLINK: Completa o Object File e o transforma em uma ROM, porém, ainda não funcional.
3. RGBFIX: Faz o fix da ROM, tornando-a funcional de fato.

## Executando tudo de uma vez

```sh
rgbasm -o hello-world.o hello-world.asm && \
rgblink -o hello-world.gb hello-world.o && \
rgbfix -v -p 0xFF hello-world.gb && \
java -jar ../Emulicious/Emulicious.jar hello-world.gb
```
