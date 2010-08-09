gas_boot3: prin-v1.bin prin4-part2.bin_gas
	dd bs=512 conv=notrunc if=prin-v1.bin of=floppy.img 
	dd bs=512 seek=1 conv=notrunc if=prin4-part2.bin_gas of=floppy.img 

prin4-part2.bin_gas: prin4-part2.S
	#as  -o prin4-part2.o_gas prin4-part2.gas
	#ld -Ttext 0x0 --oformat binary -o prin4-part2.bin_gas  prin4-part2.o_gas
	gcc -nostdinc -c -o prin4-part2.o $<
	#ld -Ttext 0x0000 --oformat binary -o prin4-part2.bin_gas  prin4-part2.o
	#ld -Ttext 0x1000 --oformat binary -o prin4-part2.bin_gas  prin4-part2.o
	#ld -N -e start -Tdata=0x1000 -Tbss=0x1000 -Ttext=0x1000 -o prin4-part2.bin_gas  prin4-part2.o
	ld -N -e start -Tdata=0x1000 -Tbss=0x1000 -Ttext=0x1000 -o prin4-part2.bin_gas  prin4-part2.o
	objdump -S prin4-part2.bin_gas > prin4-part2.dump
	ld --oformat binary -Tdata=0x1000 -Tbss=0x1000 -Ttext=0x1000 -o prin4-part2.bin_gas  prin4-part2.o
	#ld --oformat binary -Tdata=0x100 -Tbss=0x100 -Ttext=0x100 -o prin4-part2.bin_gas  prin4-part2.o

gas_boot2: prin-v0.bin prin3-part2.bin_gas
	dd bs=512 conv=notrunc if=prin-v0.bin of=floppy.img 
	dd bs=512 seek=1 conv=notrunc if=prin3-part2.bin_gas of=floppy.img 


prin3-part2.bin_gas: prin3-part2.S
	#as  -o prin3-part2.o_gas prin3-part2.gas
	#ld -Ttext 0x0 --oformat binary -o prin3-part2.bin_gas  prin3-part2.o_gas
	gcc -nostdinc -c -o prin3-part2.o $<
	#ld -Ttext 0x0000 --oformat binary -o prin3-part2.bin_gas  prin3-part2.o
	#ld -Ttext 0x1000 --oformat binary -o prin3-part2.bin_gas  prin3-part2.o
	ld -N -e start -Tdata=0x10000 -Tbss=0x10000 -Ttext=0x10000 -o prin3-part2.bin_gas  prin3-part2.o
	objdump -S prin3-part2.bin_gas > prin3-part2.dump
	#ld -N -e start -Tdata=0x0000 -Tbss=0x0000 -Ttext=0x0000 -o prin3-part2.bin_gas  prin3-part2.o
	#ld --oformat binary -Tdata=0x1000 -Tbss=0x1000 -Ttext=0x1000 -o prin3-part2.bin_gas  prin3-part2.o
	ld --oformat binary -Tdata=0x10000 -Tbss=0x10000 -Ttext=0x10000 -o prin3-part2.bin_gas  prin3-part2.o

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
