# My first game

Agora vai!

## Arquivos

### Essenciais
- `header.asm`: O famoso header, absolutamente necessário
- `vectors.asm`: Basicamente uma continuação do header, este trecho de código indica onde estão as funções NMI, RESET e IRQ. Lembrando que:
  - `RESET`: Início do programa
  - `NMI`: VBlank (chamado a cada VBlank, óbvio)
  - `IRQ`: Interrupções (nem todo jogo usa, mas é usado para split screen, efeitos HDMA, mid-frame effects, etc)
- `ini.asm`: Aqui fica as rotinas de **bootloader + inicialização do hardware + limpeza de memória** que todo cartucho deve ter
- `macros.asm`: Define algumas macros e atalhos para agilizar o desenvolvimento, como por exemplo atalhos para chavear os registradores entre 8 e 16 bits
- `registers.asm`: Arquivo que mapeia com nomes legíveis os endereços de registradores que o SNES utiliza
- `variables.asm`: Este arquivo declara algumas variáveis e separa espaço na RAM
- `main.asm`: Arquivo principal, o core de tudo
- `smc.cfg`: Este arquivo é necessário para instruir o linker `ld65` na estrutura que ele deve usar para compilar um jogo específico de SNES. Ele mapeia toda a estrutura do código

### Helpers
- `compile.bat`: Sequência de comando que compila o jogo e deixa tudo pronto

## Processos

Comecei preparando o background.
- Preparei 3 tiles de chão, editei e organizei eles no Aseprite, e salvei em formato PNG com color mode indexed
- Exportei também a paleta de cores desses tiles (mas acabei nem usando)
- Na ferramenta M1TE, importei a palette from image
- Na ferramenta M1TE, importei os tiles from image
- Na ferramenta M1TE, desenhei o tilemap
- Exportei palette, tiles e tilemap pela ferramenta M1TE
- Importei no código, fiz o DMA de tudo, e o BG está funcionando
