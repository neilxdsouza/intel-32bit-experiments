
gas_boot: prin-v0.bin prin2-part2.bin_gas
	ld -Ttext 0x0 --oformat binary -o prin2-part2.bin_gas  prin2-part2.o_gas
	dd bs=512 conv=notrunc if=prin-v0.bin of=floppy.img 
	dd bs=512 seek=1 conv=notrunc if=prin2-part2.bin_gas of=floppy.img 

prin2-part2.bin_gas: prin2-part2.gas
	as  -o prin2-part2.o_gas prin2-part2.gas

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
