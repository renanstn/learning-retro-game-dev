# Berg game

- O arquivo `.aseprite` já está no formato final q irá parar na PPU.
- O arquivo `.nss` (NEXXT studio) já tem o level pronto para ser carregado.
  - Exportar o tilemap como um CHR de 8 bytes (`file -> .chr -> save 8k A+B`) e upar na sessão `"CHARS"` do código com `.incbin`.
  - Exportar o level em `Canvas -> copy as text -> ASM code` e jogar na sessão `backgroundData` do código
- Compilar rodando o `compile_my_sprites`.
