# Sounds

## Referências

- https://gbdev.io/pandocs/Audio_Registers.html
- https://gbdev.gg8.se/wiki/articles/Gameboy_sound_hardware

Ativando o canal de som

```asm
    ; Activate sound on channel 1
    ld a, %10000001
    ldh [rNR52], a
```

Tocando um som simples de 'boing'

```asm
    ; Configure frequency sweep
    ld a, %00010110
    ldh [rNR10], a

    ; Configure wave length and duty cycle
    ld a, %10000000
    ldh [rNR11], a

    ; Configure volume envelope
    ld a, %11110000
    ldh [rNR12], a

    ; Configure frequency
    ld a, $00
    ldh [rNR13], a
    ld a, $c3
    ldh [rNR14], a
```
