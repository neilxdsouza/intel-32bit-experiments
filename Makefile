prin-v0.bin: prin-v0.asm
	


%.bin: %.asm
	nasm -f bin $< -o $@

make_floppy: make_floppy.c
	gcc $< -o $@
