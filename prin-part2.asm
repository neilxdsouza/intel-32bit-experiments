;	jmp part2_code
; print-part2.asm gets loaded by prin-v0.asm
[map symbols prin-part2.map]
part2_code:
	;; sanitise all the seg registers
	mov ax,cs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ah,0Eh
	mov al,':'
	int 10h
	mov ah,0Eh
	mov al,'>'
	int 10h
	mov ah,0Eh
	mov al,')'
	int 10h

	mov si, part2_loaded
	call print2_string
	;; now to test for a20 status
	;; using int 15x
	mov si, test_a20_support
	call print2_string

	mov ax,2403h
	int 15h
	jc not_supported_a20_int15
	jnc supported_a20_int15
not_supported_a20_int15:
	mov si, not_supported_a20_msg
	call print2_string
	jmp set_a20_alternative1
supported_a20_int15:
	mov si, supported_a20_msg
	call print2_string
	test bx,0x01
	jz keyb_not_supported
	mov si, supported_keybc_a20_msg
	call print2_string
	call enable_a20_using_int_15h
	;jmp infinite_loop
	jmp continue_from_here
keyb_not_supported:
	test bx,0x02
	jz port92_not_supported
	mov si, supported_port92_a20_msg
	call print2_string
port92_not_supported:
	mov si, not_supported_port92_a20_msg
	call print2_string
set_a20_alternative1:
continue_from_here:
	;; test print_hex
	mov ax, 0x1234
	call print_hex
	mov si, about_to_get_cursor_pos
	call print2_string
	call get_cursor_pos;
	;mov ax, [cursor_pos]
	;call print_hex
	;mov si, after_get_cursor_pos
	;call print2_string


test_prin_b8000:
	;mov si, reached_test_0xb8000
	;call print2_string
	mov ax,0xb800
	mov es,ax 
	mov ax, [cursor_pos]
	mov di, 2
	mul di
	mov di, ax
	;mov di,[cursor_pos]
	mov cx,21
	mov si, test_0xb8000_string
	mov ah, 0x07
start_of_loop:
	lodsb
	stosw
	dec cx
	jnz start_of_loop
	; now update the cursor position hard code the 21 chars we wrote to it
	; will figure out how to clean that up later
	call update_cursor_posn

	;mov si, after_test_0xb8000
	;call print2_string

infinite_loop:
	jmp $			; Jump here - infinite loop!

part2_loaded db 'Part 2 loaded success-fully',13,10,0
test_a20_support db 'query for a20 gate support using int 15',13,10,0
not_supported_a20_msg db 'query for a20 gate NOT supported using int 15',13,10,0
supported_a20_msg db 'query for a20 gate supported using int 15... here is the report',13,10,0
supported_keybc_a20_msg db 'a20 gate supported using ikeybc',13,10,0
supported_port92_a20_msg db 'a20 gate supported using port 0x92 ',13,10,0
not_supported_port92_a20_msg db 'not_supported_port92_a20_msg',13,10,0
e_setting_gate_20_msg db 'error_setting_gate_20_msg',13,10,0
success_setting_gate_20_msg db 'success_setting_gate_20_msg',13,10,0
test_0xb8000_string db 'This is a test string',13,10,0
reached_test_0xb8000 db 'reached_test_0xb8000',13,10,0
after_test_0xb8000 db 'after_test_0xb8000',13,10,0
cga_base_port dw 0x3d4
cursor_pos dd  0,0,0,0
about_to_get_cursor_pos db 'about_to_get_cursor_pos',13,10,0
after_get_cursor_pos db 'after_get_cursor_pos',13,10,0

print2_string:
	mov ah, 0Eh
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat
.done:
	ret

enable_a20_using_int_15h:
	mov ax, 2401h
	int 15h
	jc .e_setting_a20
	jnc .a20_set_successfully
.e_setting_a20:
	mov si,e_setting_gate_20_msg

	call print2_string
	ret
.a20_set_successfully:
	mov si, success_setting_gate_20_msg
	call print2_string
	ret

enable_a20_using_keybc:

.wait_keybc_ready:
	%define keybc_8043_csr 0x64
	%define inp_buffer_status 2
	in al, keybc_8043_csr
	test al, inp_buffer_status
	jnz .wait_keybc_ready
	mov al, 0xd1 	; write output port - refer ralf brown - PORTS.A
	out keybc_8043_csr, al
.wait_keybc_ready2:
	in al, keybc_8043_csr
	test al, inp_buffer_status
	jnz .wait_keybc_ready2
	mov al, 0xdf	; command 0xdf: enable a20
	out keybc_8043_csr, al	; send command to controller
.wait_keybc_ready3:
	in al, keybc_8043_csr
	test al, inp_buffer_status
	jnz .wait_keybc_ready3
	ret


get_cursor_pos:
	push dx
	push ax
	push cx
	mov dx, [cga_base_port]
	mov al, 14
	out dx,al
	inc dx
	in al,dx
	mov ch,al; higher byte of cursor pos
	dec dx
	mov al,15; 
	out dx,al
	inc dx
	in al, dx
	mov cl, al; lower word of cursor pos
	mov [cursor_pos],cx
	pop cx
	pop ax
	pop dx
	ret

update_cursor_posn:
	pusha
	mov dx, [cga_base_port]
	mov al, 14
	out dx, al
	inc dx
	mov ax, [cursor_pos]
	add ax, 21
	shr ax, 8
	out dx, al

	mov dx, [cga_base_port]
	mov al, 15
	out dx, al
	inc dx
	mov ax, [cursor_pos]
	add ax, 21
	out dx, al

	mov [cursor_pos],ax
	popa
	ret

	; char is in al
	; right now putchar does not handle things like newline etc
put_char:
	pusha
	push es;
	mov cx, ax; save char here because we need to use mul to scale di by word size=2
	mov bx, [cga_base_port]
	mov es, bx
	mov di, [cursor_pos]
	mov ax, 2
	mul di; di = di *2 - screen is wordsize (in 16 bit mode that is 2 bytes)
	mov cx,ax; restore the character back into ax - we are ready for a stosw
	stosw
	; di will be incremented automatically
	mov ax, 25*80*2
	cmp di, ax
	jae .scroll_screen
	jmp .end
.scroll_screen:
	call scroll_screen
.end:
	pop es
	popa
	ret

scroll_screen:
	pusha
	push ds
	push es
	cld; 
	mov ax, 0xb800
	mov ds, ax
	mov es, ax
	mov si, 80*2
	mov di, 0
	mov cx, 25*80-80; we want to move the 1st 24 lines up by one line 
		;- since we are using stosw we dont have to mutiply by 2
	rep movsw
	mov ax, 0x0720; space char =al, 0x07 = black on white
	mov di, 25 *80*2-80*2; last line of screen
	mov cx, 80
	rep stosw
	pop es
	pop ds
	popa

	

; data to be printed is in ax
print_hex:
	pusha
	mov dx, ax; save it for later retrieval
	shr ax, 12
	mov cx, 0x000f
	and ax, cx
	cmp ax, 9
	jbe less_than_9
	jmp greater_than_9
less_than_9:
	add al, 48
	jmp print_the_hex_digit
greater_than_9:
	add al, 55; 10 + 55 = 65 = ascii value for A
print_the_hex_digit:
	mov ah, 0Eh
	int 10h

	mov ax, dx; retrieve ax we clobbered
	shr ax, 8
	and ax, cx
	cmp ax, 9
	jbe less_than_9_1
	jmp greater_than_9_1
less_than_9_1:
	add al, 48
	jmp print_the_hex_digit_1
greater_than_9_1:
	add al, 55; 10 + 55 = 65 = ascii value for A
print_the_hex_digit_1:
	mov ah, 0Eh
	int 10h


	mov ax, dx; retrieve ax we clobbered
	shr ax, 4
	and ax, cx
	cmp ax, 9
	jbe less_than_9_2
	jmp greater_than_9_2
less_than_9_2:
	add al, 48
	jmp print_the_hex_digit_2
greater_than_9_2:
	add al, 55; 10 + 55 = 65 = ascii value for A
print_the_hex_digit_2:
	mov ah, 0Eh
	int 10h

	mov ax, dx; retrieve ax we clobbered
	;shr ax, 0
	and ax, cx
	cmp ax, 9
	jbe less_than_9_3
	jmp greater_than_9_3
less_than_9_3:
	add al, 48
	jmp print_the_hex_digit_3
greater_than_9_3:
	add al, 55; 10 + 55 = 65 = ascii value for A
print_the_hex_digit_3:
	mov ah, 0Eh
	int 10h

	popa
	ret
