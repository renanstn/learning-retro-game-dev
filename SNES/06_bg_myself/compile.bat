..\tools\cc65_bin_win\ca65.exe --cpu 65816 -o output.o main.asm
..\tools\cc65_bin_win\ld65.exe -C lorom256k.cfg output.o -o game.smc
del output.o
..\tools\Mesen_2.1.1_Windows\Mesen.exe game.smc
