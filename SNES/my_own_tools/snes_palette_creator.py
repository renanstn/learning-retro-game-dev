import argparse
import struct
from pathlib import Path

from PIL import Image


def extract_colors(image: Image.Image) -> list[tuple[int, int, int]]:
    rgb_image = image.convert("RGB")
    # First color is always transparent
    colors = [(0, 0, 0)]
    seen = {(0, 0, 0)}
    for color in rgb_image.get_flattened_data():
        if color not in seen:
            seen.add(color)
            colors.append(color)
    return colors


def rgb_to_snes(r: int, g: int, b: int) -> int:
    """
    Aqui o `>> 3` está fazendo bitshift para direita.
    Isso significa dividir o valor atual por 8.
    Essa manobra é necessária por R, G e B serão valores de 0 a 255,
    e precisamos convertê-los para valores de 0 a 31.
    É basicamente uma regra de três, porém a nível de bits.
    Já o `(b5 << 10) | (g5 << 5) | r5` está fazendo o empacotamento
    dos bits, para deixar tudo nesse formato:
    BBBBB GGGGG RRRRR
    01000 10000 11111 (valores de exemplo)
    """
    r5 = r >> 3
    g5 = g >> 3
    b5 = b >> 3
    return (b5 << 10) | (g5 << 5) | r5


def snes_to_rgb(snes_color: int) -> tuple[int, int, int]:
    """
    Função que tenta converter de volta (porém com menos precisão)
    a cor no formato SNES para a cor no formato original dela.
    Utilizado somente no print final.
    """
    r5 = snes_color & 0x1F
    g5 = (snes_color >> 5) & 0x1F
    b5 = (snes_color >> 10) & 0x1F
    # Expand 5-bit to 8-bit
    r8 = (r5 << 3) | (r5 >> 2)
    g8 = (g5 << 3) | (g5 >> 2)
    b8 = (b5 << 3) | (b5 >> 2)
    return (r8, g8, b8)


def convert_colors_to_snes(colors: list[tuple[int, int, int]]) -> list[int]:
    snes_colors = []
    for r, g, b in colors:
        snes_color = rgb_to_snes(r, g, b)
        snes_colors.append(snes_color)
    return snes_colors


def save_snes_palette(snes_colors: list[int], output_path: Path) -> None:
    """
    Aqui, o struct transforma os valores "puros" em python em valores de
    fato binários. E o `<H` indica que vamos organizar esses bits em
    little-endian, que é o formato que o SNES espera.
    Ou seja, o valor `223F` é salvo `3F 22` em little little-endian.
    """
    with open(output_path, "wb") as f:
        for snes_color in snes_colors:
            f.write(struct.pack("<H", snes_color))


def print_palette(snes_colors: list[int]) -> None:
    print("\nPalette Preview:\n")
    for index, snes_color in enumerate(snes_colors):
        r, g, b = snes_to_rgb(snes_color)
        block = f"\x1b[48;2;{r};{g};{b}m  \x1b[0m"
        print(f"{index:03} ${snes_color:04X} RGB({r:3}, {g:3}, {b:3}) {block}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert PNG image to SNES .pal palette"
    )
    parser.add_argument(
        "-i",
        "--input",
        required=True,
        type=Path,
        help="Input PNG image",
    )
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        type=Path,
        help="Output SNES palette file",
    )
    args = parser.parse_args()
    image = Image.open(args.input)
    colors = extract_colors(image)
    print(
        f"Found {len(colors)} colors (One of them is automatically set as transparent.)"
    )
    if len(colors) > 256:
        print("ERROR: image contains more than 256 colors")
        return
    snes_colors = convert_colors_to_snes(colors)
    save_snes_palette(snes_colors, args.output)
    print(f"Palette saved to: {args.output}")
    print_palette(snes_colors)


if __name__ == "__main__":
    main()
