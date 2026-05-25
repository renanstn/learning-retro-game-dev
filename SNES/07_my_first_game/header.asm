.segment "HEADER"

.byte "EXAMPLE 1            " ; rom name, must have 21 chars
.byte $20    ; define LoROM SlowROM, possible values:
             ; $20	LoROM SlowROM
             ; $30	LoROM FastROM
             ; $21	HiROM SlowROM
             ; $31	HiROM FastROM
.byte $00    ; extra chips in cartridge, 00: no extra RAM; 02: RAM with battery
.byte $08    ; ROM size. Format 2^N KB, so 2^8 KB = 256 KB
.byte $00    ; backup RAM size
.byte $01    ; region: US
.byte $33    ; publisher id
.byte $00    ; ROM revision number
.word $0000  ; checksum of all bytes
.word $0000  ; $FFFF minus checksum
