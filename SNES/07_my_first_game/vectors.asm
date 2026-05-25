.segment "VECTORS"

; native mode vectors
.word $0000
.word $0000

.addr IRQ_end
.addr IRQ_end
.addr $0000
.addr NMI
.addr RESET
.addr IRQ

.word $0000
.word $0000

; emulation mode vectors
.addr IRQ_end
.addr $0000
.addr $0000
.addr IRQ_end
.addr RESET
.addr IRQ_end
