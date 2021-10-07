[global bootloader_start]
[global loader_gdt]
[global open_pm32]
[global close_irp]
[global open_a20]
[global entry_32]
[global clean_flush]
[global boot_flags]
[global read_kernel]
[global check_status]
[global read_data]
	
bootloader_start:
;;==========Set GDT Start==========
	mov bx, [gdt_base + code_base]
	mov ax, 0x0
	mov ds, ax
	mov dword [ds:bx + 0x0], 0x0
	mov dword [ds:bx + 0x4], 0x0

;;---Set BOOT Code Description---
	mov dword [ds:bx + 0x8], 0x7c000200
	mov dword [ds:bx + 0xc], 0x00409800

;;---Set Videos Description---
	mov dword [ds:bx + 0x10], 0x80000fa0
	mov dword [ds:bx + 0x14], 0x00c0920b

;;==========Set GDT End==========
loader_gdt:
	lgdt [cs:gdt_size + code_base]
	
open_a20:
	mov dx, 0x92
	in ax, dx
	or ax, 0x2
	out dx, ax

close_irp:
	cli

open_pm32:
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

clean_flush:
	jmp dword 0x0008:read_kernel

[bits 32]
read_kernel:
	mov dx, 0x1f1
	mov al, 0x0
	out dx, al
	out dx, al

	mov dx, 0x1f2
	mov al, 0x80
	out dx, al
	mov al, 0x00
	out dx, al

	mov dx, 0x1f3
	mov al, lba_addr_24to31
	out dx, al
	mov al, lba_addr_0to7
	out dx, al

	mov dx, 0x1f4
	mov al, lba_addr_32to39
	out dx, al
	mov al, lba_addr_8to15
	out dx, al

	mov dx, 0x1f5
	mov al, lba_addr_40to47
	out dx, al
	mov al, lba_addr_16to23
	out dx, al

	mov dx, 0x1f6
	mov al, 0100_0000B
	out dx, al

	mov dx, 0x1f7
	mov al, 0x24
	out dx, al

check_status:
	mov dx, 0x1f7
	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz check_status

read_data:
	

entry_32:
	mov ax, 0x10
	mov es, ax
	mov byte [es:0x0], 'P'
	mov byte [es:0x2], 'm'
	mov byte [es:0x4], 'O'
	mov byte [es:0x6], 'K'
	mov ax, 0x10
	mov ds, ax
	hlt

boot_flags:
lba_addr_0to7: equ 0000_0001B
lba_addr_8to15: equ 0000_0000B
lba_addr_16to23: equ 0000_0000B
lba_addr_24to31: equ 0000_0000B
lba_addr_32to39: equ 0000_0000B
lba_addr_40to47: equ 0000_0000B

code_base: equ 0x7c00
gdt_size: dw 0xffff
gdt_base: dd 0x00007e00

bootloader_end:
	times 510-($-$$) db 0x0
	db 0x55, 0xaa
