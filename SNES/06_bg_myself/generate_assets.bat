:: Step 1: Resize image -------------------------

magick raw_data\image.jpeg ^
    -resize 256x256 ^
    -background black ^
    -gravity center ^
    -extent 256x256 ^
    raw_data\00_resized_output.png

:: Step 2: Palette quantizer --------------------

magick raw_data\00_resized_output.png ^
    -remap raw_data\palette.png ^
    raw_data\01_quantized_output.png

:: Step 3: Generate assets ----------------------

..\tools\superfamiconv.exe ^
    -v ^
    --mode snes ^
    --in-image raw_data\01_quantized_output.png ^
    --out-palette image.pal ^
    --out-tiles image.chr ^
    --out-map image.map ^
    --out-tiles-image tiles_preview.png ^
    --out-scaled-image map_preview.png
