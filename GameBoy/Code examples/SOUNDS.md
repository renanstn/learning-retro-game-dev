# Playing sounds

Activate sound channel

```asm
    ; Activate sound on channel 1
    ld a, %10000001
    ldh [rNR52], a
```

Play a simple "bounce" sound

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
