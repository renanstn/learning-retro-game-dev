..\tools\cc65_bin_win\ca65.exe --cpu 65816 -o output.o hello.asm
..\tools\cc65_bin_win\ld65.exe -C smc.cfg output.o -o hello.smc
del output.o
..\tools\Mesen_2.1.1_Windows\Mesen.exe hello.smc
