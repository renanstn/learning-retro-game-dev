# My own tools

As ferramentas desta pasta são de minha própria autoria.

## Preparando

Crie e ative um venv

```shell
python3 -m venv .venv
source .venv/bin/activate
```

Instale as dependências

```shell
pip install --upgrade pip
pip install -r requirements.txt
```

## Tools

### snes_palette_creator.py

Recebe uma imagem `PNG` e converte as cores para o padrão SNES, gerando uma paleta de cores em formato `.pal`.
Isso é necessário pois o SNES utiliza um formato diferente de cores: RGB555 (15-bit color).
Neste formato, apenas 5 bits representam o R, o G e o B. Totalizando 15 bits.
Na memõria, cada cor da paleta fica assim:

```
bit: 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
     x  B  B  B  B  B  G G G G G R R R R R
```

> O bit 15 não é usado!

Por causa desse formato, cada cor é representada por valores de `0 a 31`, e não `0 a 255` como normalmente acontece.

Este programinha converte as cores do formato `0-255` para `0-31`.

Uso:

```shell
python snes_palette_creator.py -i <input.png> -o <output.pal>
```
