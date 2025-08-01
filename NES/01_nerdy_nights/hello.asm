.inesprg 1   ; 1x 16KB bank of PRG code
.ineschr 1   ; 1x 8KB bank of CHR data
.inesmap 0   ; mapper 0 = NROM, no bank swapping
.inesmir 1   ; background mirroring (ignore for now)

  .bank 0
  .org $C000
;some code here

  .bank 1
  .org $E000
; more code here

  .bank 2
  .org $0000
; graphics here
