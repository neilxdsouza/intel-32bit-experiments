prinv1boot: prin-v0.bin prin2-part2.bin
	dd bs=512 conv=notrunc if=prin-v0.bin of=floppy.img 
	dd bs=512 seek=1 conv=notrunc if=prin2-part2.bin of=floppy.img 

prinv0boot: prin-v0.bin prin-part2.bin
	dd bs=512 conv=notrunc if=prin-v0.bin of=floppy.img 
	dd bs=512 seek=1 conv=notrunc if=prin-part2.bin of=floppy.img 


%.bin: %.asm
	nasm -f bin $< -o $@

make_floppy: make_floppy.c
	gcc $< -o $@
