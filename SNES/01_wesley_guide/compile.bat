C:\Users\renan\Downloads\cc65-snapshot-win32\bin\ca65  --cpu 65816 -o background.o part_01.asm && ^
C:\Users\renan\Downloads\cc65-snapshot-win32\bin\ld65 -C lorom.cfg background.o -o background.smc && ^
del background.o && ^
C:\Users\renan\Downloads\Mesen_2.1.1_Windows\Mesen.exe background.smc
