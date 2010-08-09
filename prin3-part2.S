#include "x386cpu.h"

#	jmp part2_code
# print-part2.asm gets loaded by prin-v0.asm
# this file was called prin2-part2.gas -> but it was frozen
# once I got the putchar working - now we want to transition to 32 bit protected mode
.code16
.globl _start
_start:
	## sanitise all the seg registers
	cld
	cli
	xorw	%ax,%ax			# Segment number zero
	movw	%ax,%ds			# -> Data Segment
	movw	%ax,%es			# -> Extra Segment
	movw	%ax,%ss			# -> Stack Segment
	jmp start2

# the problem with this is earlier i was loading to 0x10000 but compiling with ld -Ttext=0x0000
# this would work but required loading ds = 0x1000 , otherwise the code would not find the variable

cga_base_port: .word 0x3d4
cursor_pos: .word 0x0000

get_cursor_pos:
	pushw %dx
	pushw %ax
	pushw %cx
	#pushw %ds # this is new
	#movw $0x1000, %ax # this is new
	#	movw %ax, %ds # this is new
	#mov dx, [cga_base_port]
	#mov $0x1000:cga_base_port, %dx # this didnt compile
	mov %ds:cga_base_port, %dx
	mov $14, %al
	outb %al, %dx
	incw %dx
	inb %dx, %al
	movb %al, %ch# higher byte of cursor pos
	decw %dx
	movb $15, %al# 
	outb %al, %dx
	incw %dx
	inb %dx, %al
	movb %al, %cl# lower word of cursor pos
	#mov [cursor_pos],cx
	mov %cx, %ds:cursor_pos
	popw %cx
	popw %ax
	popw %dx
	ret

#-----------
update_cursor_posn2:
	pusha
	movw %ds:cga_base_port,%dx
	movb $14, %al
	outb %al, %dx
	incw %dx
	#movw ax, [cursor_pos]
	movw %ds:cursor_pos, %ax
	add $1, %ax
	shr $8, %ax
	outb %al, %dx
	####
	#mov dx, [cga_base_port]
	mov %ds:cga_base_port, %dx
	mov $15, %al
	outb %al, %dx
	incw %dx
	movw %ds:cursor_pos, %ax
	#add ax, 1
	addw $1, %ax
	outb %al, %dx
	####
	#mov [cursor_pos],ax# think this is not necessary - put_char already updates the new location index - 
	# this function's job is just to display this updated position on the screen
	popa
	ret
#--------
#

	# char is in al
	# right now put_char does not handle things like newline etc
put_char:
	pusha
	pushw %es#
	movw %ax, %cx# save char here because we need to use mul to scale di by word size=2
	movw $0xb800, %bx
	movw %bx, %es
	#mov di, [cursor_pos]
	movw %ds:cursor_pos, %di
	movw $2, %ax
	mulw %di# di = di *2 - screen is wordsize (in 16 bit mode that is 2 bytes)
	movw %ax, %di# transfer the new scaled index back into di from ai - the mul operation above left the answer in ax
	movw %cx, %ax# restore the character back into ax - we are ready for a stosw
	movb $0x07, %ah
	stosw
	# di will be incremented automatically by 2 and this is the new cursor_pos
	movw $(25*80*2), %ax
	cmpw %ax, %di
	jae local_scroll_screen
	jmp update_cursor_posn
local_scroll_screen:
	call scroll_screen# and scroll_screen will update the cursor position for us
	jmp end
update_cursor_posn:
	shr $1,%di# divide di by 2 when storing it back to its mem location
	movw %di, %ds:cursor_pos
	call update_cursor_posn2
end:
	popw %es
	popa
	ret

	# scroll the screen and update cursor position
scroll_screen:
	pusha
	push %ds
	push %es
	cld# 
	movw $0xb800, %ax
	movw %ax, %ds
	movw %ax, %es
	movw $(80*2), %si
	movw $0, %di
	movw $(25*80-80), %cx# we want to move the 1st 24 lines up by one line 
		#- since we are using stosw we dont have to mutiply by 2
	rep movsw
	movw $0x0720, %ax# space char =al, 0x07 = black on white
	movw $(25*80*2-80*2), %di# last line of screen
	movw $80, %cx
	rep stosw# write space to the last line - i.e. clear it out
	movw $(25*80-80), %di# new cursor position - here we dont multiply by 2 - when the routine loads the cursor position there it multiplies by 2
	movw $0x1000, %ax# not having this statement was a bug here - 
	movw %ax, %ds# mov instructions reference the ds segment, reload the original value
	movw %di, %ds:cursor_pos
	popw %es
	popw %ds
	popa
	ret

	## print the same stuff using the new put_char
	##mov ah,0Eh
	##mov al,':'
	##int 10h
	##mov ah,0Eh
	##mov al,'>'
	##int 10h
	##mov ah,0Eh
	##mov al,')'
	##int 10h
start2:
	cli
	cld
	mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	call get_cursor_pos#
top_of_loop:
	movb $':',%al
	call put_char
	movb $'>', %al
#	call put_char
#	movb $'A', %al
#	call put_char
#	movb $'B', %al
#	call put_char
#	movb $'C', %al
#	call put_char
#	movb $'D', %al
#	call put_char
#	movb $'E', %al
#	call put_char
#	movb $'F', %al
#	call put_char
#	movb $'G', %al
#	call put_char
#	movb $'H', %al
#	call put_char
#	movb $'I', %al
#	call put_char
#	movb $'J', %al
#	call put_char
#	movb $'k', %al
#	call put_char
#	movb $'l', %al
#	call put_char
#	movb $'M', %al
#	call put_char
#	movb $'N', %al
#	call put_char
#	movb $'O', %al
#	call put_char
#	movb $'P', %al
#	call put_char
#	movb $'Q', %al
#	call put_char
#	movb $'R', %al
#	call put_char
#	movb $'S', %al
#	call put_char
#	movb $'T', %al
#	call put_char
#	movb $'U', %al
#	call put_char
#	movb $'V', %al
#	call put_char
#	movb $'W', %al
#	call put_char
#	movb $'X', %al
#	call put_char
#	movb $'Y', %al
#	call put_char
#	movb $'Z', %al
#	call put_char
#	movb $'0', %al
#	call put_char
#	movb $'1', %al
#	call put_char
#	movb $'2', %al
#	call put_char
#	movb $'3', %al
#	call put_char
#	movb $'4', %al
#	call put_char
#	movb $'5', %al
#	call put_char
#	movb $'7', %al
#	call put_char
#	movb $'6', %al
#	call put_char

#enable a20
seta20.1:	inb	$0x64,%al		# Get status
		testb	$0x2,%al		# Busy?
		jnz	seta20.1		# Yes
		movb	$0xd1,%al		# Command: Write
		outb	%al,$0x64		#  output port
seta20.2:	inb	$0x64,%al		# Get status
		testb	$0x2,%al		# Busy?
		jnz	seta20.2		# Yes
		movb	$0xdf,%al		# Enable
		outb	%al,$0x60		#  A20

	#jmp top_of_loop
	cli
	#lgdt gdt_location_and_limit
	lgdt gdtdesc
	movl	%cr0, %eax	# Turn on protected mode
        orl	$0x01, %eax
        movl	%eax, %cr0
	ljmp $0x08,$protcseg
	#ljmp $0x08,$0x100f8
protcseg: .code32
	movw	$0x10, %ax	# Our data segment selector
	movw	%ax, %ds		# -> DS: Data Segment
	movw	%ax, %es		# -> ES: Extra Segment
	movw	%ax, %fs		# -> FS
	movw	%ax, %gs		# -> GS
	movw	%ax, %ss		# -> SS: Stack Segment
top_of_32_bit_loop:
	movb $'3', %al
	call put_char_32bit
	movb $'2', %al
	call put_char_32bit
	movb $' ', %al
	call put_char_32bit
	movb $'b', %al
	call put_char_32bit
	movb $'i', %al
	call put_char_32bit
	movb $'t', %al
	call put_char_32bit
	jmp top_of_32_bit_loop



#	mov si, part2_loaded
#	call print2_string
#	## now to test for a20 status
#	## using int 15x
#	mov si, test_a20_support
#	call print2_string
#
#	mov ax,2403h
#	int 15h
#	jc not_supported_a20_int15
#	jnc supported_a20_int15
#not_supported_a20_int15:
#	mov si, not_supported_a20_msg
#	call print2_string
#	jmp set_a20_alternative1
#supported_a20_int15:
#	mov si, supported_a20_msg
#	call print2_string
#	test bx,0x01
#	jz keyb_not_supported
#	mov si, supported_keybc_a20_msg
#	call print2_string
#	call enable_a20_using_int_15h
#	#jmp infinite_loop
#	jmp continue_from_here
#keyb_not_supported:
#	test bx,0x02
#	jz port92_not_supported
#	mov si, supported_port92_a20_msg
#	call print2_string
#port92_not_supported:
#	mov si, not_supported_port92_a20_msg
#	call print2_string
#set_a20_alternative1:
#continue_from_here:
#	## test print_hex
#	mov ax, 0x1234
#	call print_hex
#	mov si, about_to_get_cursor_pos
#	call print2_string
#	call get_cursor_pos#
#	#mov ax, [cursor_pos]
#	#call print_hex
#	#mov si, after_get_cursor_pos
#	#call print2_string
#
#
#test_prin_b8000:
#	#mov si, reached_test_0xb8000
#	#call print2_string
#	mov ax,0xb800
#	mov es,ax 
#	mov ax, [cursor_pos]
#	mov di, 2
#	mul di
#	mov di, ax
#	#mov di,[cursor_pos]
#	mov cx,21
#	mov si, test_0xb8000_string
#	mov ah, 0x07
#start_of_loop:
#	lodsb
#	stosw
#	dec cx
#	jnz start_of_loop
#	# now update the cursor position hard code the 21 chars we wrote to it
#	# will figure out how to clean that up later
#	call update_cursor_posn
#
#	#mov si, after_test_0xb8000
#	#call print2_string
#
#infinite_loop:
#	jmp $			# Jump here - infinite loop!
#
#part2_loaded db 'Part 2 loaded success-fully',13,10,0
#test_a20_support db 'query for a20 gate support using int 15',13,10,0
#not_supported_a20_msg db 'query for a20 gate NOT supported using int 15',13,10,0
#supported_a20_msg db 'query for a20 gate supported using int 15... here is the report',13,10,0
#supported_keybc_a20_msg db 'a20 gate supported using ikeybc',13,10,0
#supported_port92_a20_msg db 'a20 gate supported using port 0x92 ',13,10,0
#not_supported_port92_a20_msg db 'not_supported_port92_a20_msg',13,10,0
#e_setting_gate_20_msg db 'error_setting_gate_20_msg',13,10,0
#success_setting_gate_20_msg db 'success_setting_gate_20_msg',13,10,0
#test_0xb8000_string db 'This is a test string',13,10,0
#reached_test_0xb8000 db 'reached_test_0xb8000',13,10,0
#after_test_0xb8000 db 'after_test_0xb8000',13,10,0

#about_to_get_cursor_pos db 'about_to_get_cursor_pos',13,10,0
#after_get_cursor_pos db 'after_get_cursor_pos',13,10,0
#
## this routine works - but we want to use direct 
## writing to 0xb8000 
##print2_string:
##	mov ah, 0Eh
##.repeat:
##	lodsb
##	cmp al, 0
##	je .done
##	int 10h
##	jmp .repeat
##.done:
##	ret
#
### new print2_string - assume ds:si points to string
### directly dump to 0xB8000 and update cursor position
### assume ds
#print2_string:
#	pusha
#	push es#
#	cld#
#	mov ax, 0xb8000
#	mov es, ax
#	mov ax,[cursor_pos]
#	mov di, 2
#	mul di# has to be multiplied by 2 because each array slot in video memory is 2 bytes
#	mov di,ax
#	movsw
#	ret
#
#
#enable_a20_using_int_15h:
#	mov ax, 2401h
#	int 15h
#	jc .e_setting_a20
#	jnc .a20_set_successfully
#.e_setting_a20:
#	mov si,e_setting_gate_20_msg
#
#	call print2_string
#	ret
#.a20_set_successfully:
#	mov si, success_setting_gate_20_msg
#	call print2_string
#	ret
#
#enable_a20_using_keybc:
#
#.wait_keybc_ready:
#	%define keybc_8043_csr 0x64
#	%define inp_buffer_status 2
#	in al, keybc_8043_csr
#	test al, inp_buffer_status
#	jnz .wait_keybc_ready
#	mov al, 0xd1 	# write output port - refer ralf brown - PORTS.A
#	out keybc_8043_csr, al
#.wait_keybc_ready2:
#	in al, keybc_8043_csr
#	test al, inp_buffer_status
#	jnz .wait_keybc_ready2
#	mov al, 0xdf	# command 0xdf: enable a20
#	out keybc_8043_csr, al	# send command to controller
#.wait_keybc_ready3:
#	in al, keybc_8043_csr
#	test al, inp_buffer_status
#	jnz .wait_keybc_ready3
#	ret
#
#
## dumps the cursor position in cursor_pos
## treat it like a global variable 
## after a call to this function the cursor_pos is valid

## commented out code below to check if code from JOS kernel works
## I suspect endianness problem
##		.p2align 2			# force 4 byte alignment
##gdt_desc:
##	# bits 0 - 15 limit
##	# bits 16 - 39 base address
##	# bit 40 - accessed
##	# bit 41 - 43 segment type
##	# bit 44 - system bit
##	# bit 45 - 46 - descriptor privelege level
##	# bit 47 - present
##	# bit 48 - 51 - limit bit ( last 4 bits to give a total of 20 limit bits)
##	# bit 52 - user bit
##	# bit 53 - reserved by intel
##	# bit 54 - default size bit - of cleared operands are 16 bits if set 32 bits
##	# bit 55 granularity bit - if clear 20 bit limit field is in size of 1 byte if set 
##				# it is in size of 4k bytes
##	# for this file assume 32 mb of ram - what a default bochs simulates
##	# simple linear address space, no paging etc - just entering 32 bit mode is enough
##	# 32 mb =33554432 bytes = 8192 * 4096 bytes = 8192 4k blocks = 0x2000 4k blocks
##	# 1st seg is a null seg
##	.word 0, 0
##	.byte 0, 0, 0, 0
##
##	# 2nd descriptor = exec segment
##	.word 0x2000 # 2 bytes of limit
##	.word 0x0000 # 2 bytes of base - zero
##	.byte 0x00 # 1 more byte of base = note bits 16-39 of base address = 3 bytes
##	.byte ( 10 + 128) 	# accessed bit = 0 (this will be set by CPU everytime the segment is accessed)
##				# segment type executable = read + exec = 101 = 5 but bit 0 in this set is the accessed bit - so this becomes 5<<1 = 10
##				# system bit = bit 44 = 5th bit in this byte = 0 as this is not a TSS 
##				# DPL = 0 = most privileged bits 45 and 46
##				# Present bit - should be set otherwise CPU will throw a fault if you try to load this seg = 7th bit in byte (counting bits from 0) 2^7=128
##	.byte (128 + 64)	# our 32 meg limit can be expressed in the first 16 bits of the limit itself - no need for bits 16 to 19
##				# bit 54 = 6th bit (counting from 0) in this byte = set because we are a 32 bit descriptor and want 32 bit operands
##				# bit 55 = granularity bit = set because we want 4k as the counting unit for the limit
##	.byte 0			# last byte of base address = 0
##	# 3rd descriptor = read write data segment
##	.word 0x2000 # 2 bytes of limit
##	.word 0x0000 # 2 bytes of base - zero
##	.byte 0x00 # 1 more byte of base = note bits 16-39 of base address = 3 bytes
##	.byte ( 2 + 128) 	# accessed bit = 0 (this will be set by CPU everytime the segment is accessed)
##				# segment type data = read + write = 1 = 1 but bit 0 in this set is the accessed bit - so this becomes 1<<1 = 2
##				# system bit = bit 44 = 5th bit in this byte = 0 as this is not a TSS 
##				# DPL = 0 = most privileged bits 45 and 46
##				# Present bit - should be set otherwise CPU will throw a fault if you try to load this seg = 7th bit in byte (counting bits from 0) 2^7=128
##	.byte (128 + 64)	# our 32 meg limit can be expressed in the first 16 bits of the limit itself - no need for bits 16 to 19
##				# bit 54 = 6th bit (counting from 0) in this byte = set because we are a 32 bit descriptor and want 32 bit operands
##				# bit 55 = granularity bit = set because we want 4k as the counting unit for the limit
##	.byte 0			# last byte of base address = 0
##gdt_location_and_limit:
##	.word 0x17
##	.long gdt_desc
##

		.p2align 2			# force 4 byte alignment
gdt:		SEG_NULL				# null seg
		SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
		SEG(STA_W, 0x0, 0xffffffff)	        # data seg
gdtdesc:	.word	0x17			# sizeof(gdt) - 1
		.long	0x10134		# address gdt

get_cursor_pos_32bit:
	pushw %dx
	pushw %ax
	pushw %cx
	#mov dx, [cga_base_port]
	mov %ds:cga_base_port, %dx
	mov $14, %al
	outb %al, %dx
	incw %dx
	inb %dx, %al
	movb %al, %ch# higher byte of cursor pos
	decw %dx
	movb $15, %al# 
	outb %al, %dx
	incw %dx
	inb %dx, %al
	movb %al, %cl# lower word of cursor pos
	#mov [cursor_pos],cx
	mov %cx, %ds:cursor_pos
	popw %cx
	popw %ax
	popw %dx
	ret


#-----------
update_cursor_posn2_32bit:
	pusha
	movw %ds:cga_base_port,%dx
	movb $14, %al
	outb %al, %dx
	incw %dx
	#movw ax, [cursor_pos]
	movw %ds:cursor_pos, %ax
	add $1, %ax
	shr $8, %ax
	outb %al, %dx
	####
	#mov dx, [cga_base_port]
	mov %ds:cga_base_port, %dx
	mov $15, %al
	outb %al, %dx
	incw %dx
	movw %ds:cursor_pos, %ax
	#add ax, 1
	addw $1, %ax
	outb %al, %dx
	####
	#mov [cursor_pos],ax# think this is not necessary - put_char already updates the new location index - 
	# this function's job is just to display this updated position on the screen
	popa
	ret
#--------
#
#

	# char is in al
	# right now put_char does not handle things like newline etc
put_char_32bit:
	pusha
	pushw %es#
	movw %ax, %cx# save char here because we need to use mul to scale di by word size=2
	movw $0xb800, %bx
	movw %bx, %es
	#mov di, [cursor_pos]
	movw %ds:cursor_pos, %di
	movw $2, %ax
	mulw %di# di = di *2 - screen is wordsize (in 16 bit mode that is 2 bytes)
	movw %ax, %di# transfer the new scaled index back into di from ai - the mul operation above left the answer in ax
	movw %cx, %ax# restore the character back into ax - we are ready for a stosw
	movb $0x07, %ah
	stosw
	# di will be incremented automatically by 2 and this is the new cursor_pos
	movw $(25*80*2), %ax
	cmpw %ax, %di
	jae local_scroll_screen_32bit
	jmp update_cursor_posn_32bit
local_scroll_screen_32bit:
	call scroll_screen_32bit# and scroll_screen will update the cursor position for us
	jmp end_32bit
update_cursor_posn_32bit:
	shr $1,%di# divide di by 2 when storing it back to its mem location
	movw %di, %ds:cursor_pos
	call update_cursor_posn2_32bit
end_32bit:
	popw %es
	popa
	ret


	# scroll the screen and update cursor position
scroll_screen_32bit:
	pusha
	push %ds
	push %es
	cld# 
	movw $0xb800, %ax
	movw %ax, %ds
	movw %ax, %es
	movw $(80*2), %si
	movw $0, %di
	movw $(25*80-80), %cx# we want to move the 1st 24 lines up by one line 
		#- since we are using stosw we dont have to mutiply by 2
	rep movsw
	movw $0x0720, %ax# space char =al, 0x07 = black on white
	movw $(25*80*2-80*2), %di# last line of screen
	movw $80, %cx
	rep stosw# write space to the last line - i.e. clear it out
	movw $(25*80-80), %di# new cursor position - here we dont multiply by 2 - when the routine loads the cursor position there it multiplies by 2
	movw $0x1000, %ax# not having this statement was a bug here - 
	movw %ax, %ds# mov instructions reference the ds segment, reload the original value
	movw %di, %ds:cursor_pos
	popw %es
	popw %ds
	popa
	ret

# data to be printed is in ax
#print_hex:
#	pusha
#	mov dx, ax# save it for later retrieval
#	shr ax, 12
#	mov cx, 0x000f
#	and ax, cx
#	cmp ax, 9
#	jbe less_than_9
#	jmp greater_than_9
#less_than_9:
#	add al, 48
#	jmp print_the_hex_digit
#greater_than_9:
#	add al, 55# 10 + 55 = 65 = ascii value for A
#print_the_hex_digit:
#	mov ah, 0Eh
#	int 10h
#
#	mov ax, dx# retrieve ax we clobbered
#	shr ax, 8
#	and ax, cx
#	cmp ax, 9
#	jbe less_than_9_1
#	jmp greater_than_9_1
#less_than_9_1:
#	add al, 48
#	jmp print_the_hex_digit_1
#greater_than_9_1:
#	add al, 55# 10 + 55 = 65 = ascii value for A
#print_the_hex_digit_1:
#	mov ah, 0Eh
#	int 10h
#
#
#	mov ax, dx# retrieve ax we clobbered
#	shr ax, 4
#	and ax, cx
#	cmp ax, 9
#	jbe less_than_9_2
#	jmp greater_than_9_2
#less_than_9_2:
#	add al, 48
#	jmp print_the_hex_digit_2
#greater_than_9_2:
#	add al, 55# 10 + 55 = 65 = ascii value for A
#print_the_hex_digit_2:
#	mov ah, 0Eh
#	int 10h
#
#	mov ax, dx# retrieve ax we clobbered
#	#shr ax, 0
#	and ax, cx
#	cmp ax, 9
#	jbe less_than_9_3
#	jmp greater_than_9_3
#less_than_9_3:
#	add al, 48
#	jmp print_the_hex_digit_3
#greater_than_9_3:
#	add al, 55# 10 + 55 = 65 = ascii value for A
#print_the_hex_digit_3:
#	mov ah, 0Eh
#	int 10h
#
#	popa
#	ret
