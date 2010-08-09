; This is a program by Daniel Majaramaki - 
; I have modified it a bit.
; It reads a 5 sectors from the floppy
; starting from sector 2 and tries to 
; execute it
BITS 16
org 0
jmp 07c0h:start;
start:
	mov ax, cs		; Set up 4K stack space after this bootloader
	mov ds, ax
	mov es, ax
	mov ax, 8192		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov si, try_reset
	call print_string
reset:                      ; Reset the floppy drive
	mov ax, 0           ;
	mov dl, 0           ; Drive=0 (=A)
	int 13h             ;
	jc reset            ; ERROR => reset again
	mov si, reset_success
	call print_string

read:
	mov ax, 1000h       ; ES:BX = 1000:0000 => 0x10000
	mov es, ax          ;
	mov bx, 0           ;

	mov ah, 2           ; Load disk data to ES:BX
	mov al, 5           ; Load 5 sectors
	mov ch, 0           ; Cylinder=0
	mov cl, 2           ; Sector=2
	mov dh, 0           ; Head=0
	mov dl, 0           ; Drive=0
	int 13h             ; Read!

	jc read             ; ERROR => Try again
	mov si, read_success
	call print_string

	jmp 1000h:0000      ; Jump to the program


try_reset db 'try reset fdc', 13,10,0
reset_success db 'reset fdc success!', 13,10,0
read_success db 'read fdc success!', 13,10,0


print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh		; int 10h 'print char' function

.repeat:
	lodsb			; Get character from string
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .repeat

.done:
	ret


	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
