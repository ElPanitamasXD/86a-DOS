org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld
    mov [boot_drive], dl

    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov byte [cur_cyl], 0
    mov byte [cur_head], 0
    mov byte [cur_sector], 2
    call read_one_sector
    jc disk_error

    cmp word [es:0], 0x3638
    jne disk_error
    cmp word [es:2], 0x4B41
    jne disk_error

    mov ax, [es:4]
    cmp ax, 1
    jb disk_error
    cmp ax, 120
    ja disk_error
    mov [sectors_left], ax
    dec word [sectors_left]

    mov ax, [es:6]
    mov [entry_offset], ax

    mov bx, 512
    inc byte [cur_sector]

load_kernel_loop:
    cmp word [sectors_left], 0
    je launch_kernel
    call read_one_sector
    jc disk_error
    add bx, 512
    dec word [sectors_left]
    inc byte [cur_sector]
    cmp byte [cur_sector], 19
    jb load_kernel_loop
    mov byte [cur_sector], 1
    inc byte [cur_head]
    cmp byte [cur_head], 2
    jb load_kernel_loop
    mov byte [cur_head], 0
    inc byte [cur_cyl]
    jmp load_kernel_loop

launch_kernel:
    mov ax, 0x1000
    push ax
    mov ax, [entry_offset]
    push ax
    retf

read_one_sector:
    mov byte [retry_count], 3
read_retry:
    mov ax, 0x1000
    mov es, ax
    mov ah, 0x02
    mov al, 1
    mov ch, [cur_cyl]
    mov cl, [cur_sector]
    mov dh, [cur_head]
    mov dl, [boot_drive]
    push bx
    int 0x13
    pop bx
    jnc read_success
    push bx
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13
    pop bx
    dec byte [retry_count]
    jnz read_retry
    stc
    ret

read_success:
    clc
    ret

disk_error:
    xor ax, ax
    mov ds, ax
    mov ax, 0x0003
    int 0x10
    mov si, error_message
error_print:
    lodsb
    test al, al
    jz error_halt
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp error_print

error_halt:
    cli
halt_loop:
    hlt
    jmp halt_loop

boot_drive db 0
cur_cyl db 0
cur_head db 0
cur_sector db 2
retry_count db 0
sectors_left dw 0
entry_offset dw 0
error_message db '86a-DOS: boot/kernel read error',13,10,0

times 510-($-$$) db 0
dw 0xAA55
