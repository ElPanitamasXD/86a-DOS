org 0x0000
bits 16

kernel_header:
    db '86AK'
    dw kernel_sectors
    dw kernel_entry
    times 8 db 0

kernel_entry:
    jmp boot

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
VIDEO_SEG equ 0A000h
COLOR_BLACK equ 00h
COLOR_WHITE equ 0Fh
CMD_SIZE equ 64
CMD_INPUT_MAX equ 31
CHAR_W equ 8
CHAR_H equ 8
TERM_LEFT equ 56
TERM_RIGHT equ 304
TERM_TOP equ 49
TERM_BOTTOM equ 184

boot:
    cli
    cld
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0FFFEh
    sti

    mov ax, 0013h
    int 10h

    call init_font
    call init_mouse
    call reset_desktop

main_loop:
    mov si, prompt_custom
    cmp byte [si], 0
    jne .prompt_ready
    mov si, prompt_default
.prompt_ready:
    call print_string
    call read_command
    call execute_command
    jmp main_loop

reset_desktop:
    call draw_gui
    mov byte [text_color], COLOR_BLACK
    mov byte [prompt_color], COLOR_BLACK
    mov byte [prompt_custom], 0
    mov si, startup_screen
    call print_string
    mov si, help_screen
    call print_string
    ret

init_font:
    push ax
    push bx
    mov ax, 1130h
    mov bh, 03h
    int 10h
    mov [font_off], bp
    mov [font_seg], es
    pop bx
    pop ax
    ret

init_mouse:
    push ax
    push bx
    push cx
    push dx
    push ds
    xor ax, ax
    mov ds, ax
    mov bx, [33h*4]
    mov cx, [33h*4+2]
    pop ds
    or bx, cx
    jz .none
    xor ax, ax
    int 33h
    cmp ax, 0FFFFh
    jne .none
    mov byte [mouse_enabled], 1
    mov ax, 07h
    xor cx, cx
    mov dx, 319
    int 33h
    mov ax, 08h
    xor cx, cx
    mov dx, 199
    int 33h
    mov ax, 01h
    int 33h
.none:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_gui:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp

    cmp byte [mouse_enabled], 0
    je .draw
    mov ax, 02h
    int 33h
.draw:
    mov al, COLOR_WHITE
    xor bx, bx
    xor dx, dx
    mov cx, SCREEN_WIDTH
    mov bp, SCREEN_HEIGHT
    call fill_rect

    mov al, COLOR_BLACK
    mov bx, 0
    mov dx, 14
    mov cx, SCREEN_WIDTH
    mov bp, 1
    call fill_rect
    mov dx, 16
    call fill_rect

    mov byte [draw_color], COLOR_BLACK
    mov si, ui_86a
    mov bx, 7
    mov dx, 3
    call draw_string_at
    mov si, ui_file
    mov bx, 42
    mov dx, 3
    call draw_string_at
    mov si, ui_edit
    mov bx, 82
    mov dx, 3
    call draw_string_at
    mov si, ui_view
    mov bx, 122
    mov dx, 3
    call draw_string_at
    mov si, ui_special
    mov bx, 162
    mov dx, 3
    call draw_string_at

    mov al, COLOR_BLACK
    mov bx, 8
    mov dx, 29
    mov cx, 32
    mov bp, 29
    call draw_rect
    mov al, COLOR_WHITE
    mov bx, 11
    mov dx, 32
    mov cx, 26
    mov bp, 23
    call fill_rect
    mov al, COLOR_BLACK
    mov bx, 11
    mov dx, 35
    mov cx, 26
    mov bp, 5
    call fill_rect
    mov al, COLOR_WHITE
    mov bx, 15
    mov dx, 43
    mov cx, 18
    mov bp, 8
    call fill_rect
    mov al, COLOR_BLACK
    mov bx, 15
    mov dx, 43
    mov cx, 18
    mov bp, 1
    call fill_rect
    mov si, ui_disk
    mov bx, 6
    mov dx, 60
    call draw_string_at

    mov al, COLOR_BLACK
    mov bx, 9
    mov dx, 130
    mov cx, 30
    mov bp, 25
    call draw_rect
    mov al, COLOR_WHITE
    mov bx, 12
    mov dx, 133
    mov cx, 24
    mov bp, 19
    call fill_rect
    mov al, COLOR_BLACK
    mov bx, 7
    mov dx, 127
    mov cx, 34
    mov bp, 3
    call fill_rect
    mov bx, 17
    mov dx, 136
    mov cx, 1
    mov bp, 13
    call fill_rect
    mov bx, 23
    mov cx, 1
    call fill_rect
    mov bx, 29
    mov cx, 1
    call fill_rect
    mov si, ui_trash
    mov bx, 2
    mov dx, 159
    call draw_string_at

    mov al, COLOR_BLACK
    mov bx, 47
    mov dx, 23
    mov cx, 266
    mov bp, 172
    call draw_rect
    mov al, COLOR_WHITE
    mov bx, 49
    mov dx, 25
    mov cx, 262
    mov bp, 168
    call fill_rect

    mov al, COLOR_BLACK
    mov bx, 49
    mov dx, 25
    mov cx, 262
    mov bp, 1
    call fill_rect
    mov dx, 36
    call fill_rect

    mov bx, 63
    mov dx, 27
    mov cx, 80
    mov bp, 1
    call fill_rect
    mov dx, 29
    call fill_rect
    mov dx, 31
    call fill_rect
    mov dx, 33
    call fill_rect
    mov bx, 216
    mov dx, 27
    mov cx, 92
    mov bp, 1
    call fill_rect
    mov dx, 29
    call fill_rect
    mov dx, 31
    call fill_rect
    mov dx, 33
    call fill_rect

    mov al, COLOR_BLACK
    mov bx, 52
    mov dx, 27
    mov cx, 7
    mov bp, 7
    call draw_rect
    mov al, COLOR_WHITE
    mov bx, 54
    mov dx, 29
    mov cx, 3
    mov bp, 3
    call fill_rect

    mov byte [draw_color], COLOR_BLACK
    mov si, ui_title
    mov bx, 152
    mov dx, 27
    call draw_string_at
    mov si, ui_ready
    mov bx, 56
    mov dx, 39
    call draw_string_at
    mov si, ui_resolution
    mov bx, 214
    mov dx, 39
    call draw_string_at

    mov al, COLOR_BLACK
    mov bx, 49
    mov dx, 47
    mov cx, 262
    mov bp, 1
    call fill_rect

    mov word [text_x], TERM_LEFT
    mov word [text_y], TERM_TOP

    cmp byte [mouse_enabled], 0
    je .done
    mov ax, 01h
    int 33h
.done:
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

fill_rect:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es

    mov si, ax
    mov ax, dx
    mov dx, 320
    mul dx
    add ax, bx
    mov di, ax
    mov ax, VIDEO_SEG
    mov es, ax
    mov ax, si
    mov si, 320
    sub si, cx
    mov dx, bp
    cld
.row:
    push cx
    rep stosb
    pop cx
    add di, si
    dec dx
    jnz .row

    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_rect:
    push ax
    push bx
    push cx
    push dx
    push bp

    mov byte [rect_color], al
    mov [rect_x], bx
    mov [rect_y], dx
    mov [rect_w], cx
    mov [rect_h], bp

    mov al, [rect_color]
    mov bx, [rect_x]
    mov dx, [rect_y]
    mov cx, [rect_w]
    mov bp, 1
    call fill_rect

    mov al, [rect_color]
    mov bx, [rect_x]
    mov dx, [rect_y]
    add dx, [rect_h]
    dec dx
    mov cx, [rect_w]
    mov bp, 1
    call fill_rect

    mov al, [rect_color]
    mov bx, [rect_x]
    mov dx, [rect_y]
    mov cx, 1
    mov bp, [rect_h]
    call fill_rect

    mov al, [rect_color]
    mov bx, [rect_x]
    add bx, [rect_w]
    dec bx
    mov dx, [rect_y]
    mov cx, 1
    mov bp, [rect_h]
    call fill_rect

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_string_at:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp

    mov bp, bx
.next:
    lodsb
    cmp al, 0
    je .done
    cmp al, 13
    je .cr
    cmp al, 10
    je .lf
    call draw_char
    add bx, CHAR_W
    jmp .next
.cr:
    mov bx, bp
.lf:
    add dx, CHAR_H+1
    jmp .next
.done:
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_char:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push ds
    push es

    xor ah, ah
    mov si, ax
    mov ax, dx
    mov cx, 320
    mul cx
    add ax, bx
    mov di, ax
    mov al, [draw_color]
    mov [saved_color], al

    mov ax, si
    mov cx, 8
    mul cx
    add ax, [font_off]
    mov si, ax
    mov ax, [font_seg]
    mov ds, ax
    mov ax, VIDEO_SEG
    mov es, ax

    mov bp, CHAR_H
.row:
    mov al, [si]
    inc si
    mov dl, al
    mov cx, CHAR_W
.pixel:
    test dl, 80h
    jz .skip
    mov al, [cs:saved_color]
    mov [es:di], al
.skip:
    inc di
    shl dl, 1
    loop .pixel
    add di, 320-CHAR_W
    dec bp
    jnz .row

    pop es
    pop ds
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_string:
.next:
    lodsb
    cmp al, 0
    je .done
    cmp al, 13
    je .cr
    cmp al, 10
    je .next
    call print_char
    jmp .next
.cr:
    call newline
    jmp .next
.done:
    ret

print_char:
    push bx
    push dx
    cmp al, 32
    jb .done
    mov [saved_char], al
    mov bx, [text_x]
    add bx, CHAR_W
    cmp bx, TERM_RIGHT
    jbe .draw
    call newline
    mov bx, [text_x]
.draw:
    mov dx, [text_y]
    mov al, [text_color]
    mov [draw_color], al
    mov al, [saved_char]
    call draw_char
    mov bx, [text_x]
    add bx, CHAR_W
    mov [text_x], bx
.done:
    pop dx
    pop bx
    ret

newline:
    mov word [text_x], TERM_LEFT
    mov ax, [text_y]
    add ax, CHAR_H+1
    cmp ax, TERM_BOTTOM
    jb .store
    call scroll_terminal
    mov word [text_y], TERM_BOTTOM-CHAR_H-1
    ret
.store:
    mov [text_y], ax
    ret

scroll_terminal:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push ds
    push es
    mov ax, VIDEO_SEG
    mov ds, ax
    mov es, ax
    cld
    mov si, (TERM_TOP+CHAR_H+1)*SCREEN_WIDTH+50
    mov di, TERM_TOP*SCREEN_WIDTH+50
    mov bp, TERM_BOTTOM-TERM_TOP-CHAR_H-1
.row:
    mov cx, 130
    rep movsw
    add si, SCREEN_WIDTH-260
    add di, SCREEN_WIDTH-260
    dec bp
    jnz .row
    pop es
    pop ds
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov al, COLOR_WHITE
    mov bx, 50
    mov dx, TERM_BOTTOM-CHAR_H-1
    mov cx, 260
    mov bp, CHAR_H+1
    call fill_rect
    ret

clear_terminal_view:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov al, COLOR_WHITE
    mov bx, 50
    mov dx, TERM_TOP
    mov cx, 260
    mov bp, TERM_BOTTOM-TERM_TOP
    call fill_rect
    mov word [text_x], TERM_LEFT
    mov word [text_y], TERM_TOP
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

read_command:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov byte [input_len], 0
    mov byte [cmd_buffer], 0

    mov ax, [text_x]
    mov [input_start_x], ax
    mov ax, [text_y]
    mov [input_y], ax

    call cursor_set_tick
    call render_input

.read:
    call cursor_update
    mov ah, 01h
    int 16h
    jz .read

    xor ah, ah
    int 16h

    cmp al, 0
    je .read
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    cmp al, 27
    je .escape
    cmp al, 32
    jb .read
    cmp al, 126
    ja .read

    mov [saved_input_char], al
    mov al, [input_len]
    cmp al, CMD_INPUT_MAX
    jae .read

    xor ah, ah
    mov bx, ax
    mov dx, CHAR_W
    mov ax, bx
    mul dx
    mov bx, ax
    add bx, [input_start_x]
    add bx, CHAR_W
    cmp bx, TERM_RIGHT
    ja .read

    mov al, [saved_input_char]
    mov bx, 0
    mov bl, [input_len]
    mov si, cmd_buffer
    add si, bx
    mov [si], al
    inc byte [input_len]
    mov byte [si+1], 0
    call render_input
    jmp .read

.backspace:
    cmp byte [input_len], 0
    je .read

    dec byte [input_len]
    xor bx, bx
    mov bl, [input_len]
    mov si, cmd_buffer
    add si, bx
    mov byte [si], 0
    call render_input
    jmp .read

.escape:
    mov byte [input_len], 0
    mov byte [cmd_buffer], 0
    call render_input
    call cursor_hide
    mov ax, [input_start_x]
    mov [text_x], ax
    mov ax, [input_y]
    mov [text_y], ax
    call newline
    jmp .done

.enter:
    call cursor_hide
    mov al, 0
    xor bx, bx
    mov bl, [input_len]
    mov si, cmd_buffer
    add si, bx
    mov [si], al
    call newline

.done:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

render_input:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp

    call cursor_hide

    mov bx, [input_start_x]
    mov dx, [input_y]
    mov ax, TERM_RIGHT
    sub ax, bx
    mov cx, ax
    cmp cx, 0
    jbe .position
    mov al, COLOR_WHITE
    mov bp, CHAR_H+1
    call fill_rect

.position:
    mov bx, [input_start_x]
    mov dx, [input_y]
    mov si, cmd_buffer
    mov byte [draw_color], COLOR_BLACK

.next:
    lodsb
    cmp al, 0
    je .finish
    call draw_char
    add bx, CHAR_W
    cmp bx, TERM_RIGHT
    ja .finish
    jmp .next

.finish:
    mov [text_x], bx
    mov [text_y], dx
    call cursor_show

    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

cursor_set_tick:
    push ax
    push dx
    mov ah, 00h
    int 1Ah
    mov [cursor_tick], dx
    mov byte [cursor_state], 0
    pop dx
    pop ax
    ret

cursor_show:
    push ax
    push bx
    push cx
    push dx
    push bp
    cmp byte [cursor_state], 1
    je .done
    mov bx, [text_x]
    mov dx, [text_y]
    add dx, CHAR_H
    mov al, COLOR_BLACK
    mov cx, CHAR_W
    mov bp, 1
    call fill_rect
    mov byte [cursor_state], 1
.done:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

cursor_hide:
    push ax
    push bx
    push cx
    push dx
    push bp
    cmp byte [cursor_state], 0
    je .done
    mov bx, [text_x]
    mov dx, [text_y]
    add dx, CHAR_H
    mov al, COLOR_WHITE
    mov cx, CHAR_W
    mov bp, 1
    call fill_rect
    mov byte [cursor_state], 0
.done:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

cursor_update:
    push ax
    push dx
    mov ah, 00h
    int 1Ah
    mov ax, dx
    sub ax, [cursor_tick]
    cmp ax, 9
    jb .done
    mov [cursor_tick], dx
    cmp byte [cursor_state], 0
    je .show
    call cursor_hide
    jmp .done
.show:
    call cursor_show
.done:
    pop dx
    pop ax
    ret

execute_command:
    call string_to_lower
    mov si, cmd_buffer
    call skip_spaces
    cmp byte [si], 0
    je .done

    mov di, cmd_help
    call command_match
    jc do_help
    mov di, cmd_ver
    call command_match
    jc do_ver
    mov di, cmd_about
    call command_match
    jc do_about
    mov di, cmd_cls
    call command_match
    jc do_cls
    mov di, cmd_clear
    call command_match
    jc do_cls
    mov di, cmd_echo
    call command_prefix_match
    jc do_echo
    mov di, cmd_color
    call command_prefix_match
    jc do_color
    mov di, cmd_prompt
    call command_prefix_match
    jc do_prompt
    mov di, cmd_time
    call command_match
    jc do_time
    mov di, cmd_date
    call command_match
    jc do_date
    mov di, cmd_calc
    call command_prefix_match
    jc do_calc
    mov di, cmd_mem
    call command_match
    jc do_mem
    mov di, cmd_beep
    call command_match
    jc do_beep
    mov di, cmd_dir
    call command_match
    jc do_dir
    mov di, cmd_type
    call command_prefix_match
    jc do_type
    mov di, cmd_write
    call command_prefix_match
    jc do_write
    mov di, cmd_del
    call command_prefix_match
    jc do_delete
    mov di, cmd_info
    call command_match
    jc do_info
    mov di, cmd_reboot
    call command_match
    jc do_reboot
    mov di, cmd_shutdown
    call command_match
    jc do_shutdown
    mov di, cmd_game
    call command_match
    jc do_game
    mov di, cmd_guess
    call command_match
    jc do_guess
    mov di, cmd_react
    call command_match
    jc do_react
    mov di, cmd_finder
    call command_match
    jc do_finder
    mov di, cmd_paint
    call command_match
    jc do_paint
    mov di, cmd_clock
    call command_match
    jc do_clock
    mov di, cmd_notepad
    call command_match
    jc do_notepad

    mov si, msg_bad_command
    call print_string
.done:
    ret

command_match:
    push ax
    push bx
    push si
    push di
.compare:
    mov al, [di]
    cmp al, 0
    je .command_done
    cmp al, [si]
    jne .no
    inc si
    inc di
    jmp .compare
.command_done:
    call skip_spaces_local
    cmp byte [si], 0
    jne .no
.yes:
    pop di
    pop si
    pop bx
    pop ax
    stc
    ret
.no:
    pop di
    pop si
    pop bx
    pop ax
    clc
    ret

command_prefix_match:
    push ax
    push bx
    push si
    push di
.prefix_loop:
    mov al, [di]
    cmp al, 0
    je .prefix_end
    cmp al, [si]
    jne .prefix_no
    inc si
    inc di
    jmp .prefix_loop
.prefix_end:
    mov al, [si]
    cmp al, 0
    je .prefix_yes
    cmp al, ' '
    je .prefix_yes
.prefix_no:
    pop di
    pop si
    pop bx
    pop ax
    clc
    ret
.prefix_yes:
    pop di
    pop si
    pop bx
    pop ax
    stc
    ret

skip_spaces_local:
.local:
    cmp byte [si], ' '
    jne .done
    inc si
    jmp .local
.done:
    ret

skip_spaces:
.loop:
    cmp byte [si], ' '
    jne .done
    inc si
    jmp .loop
.done:
    ret

string_to_lower:
    push ax
    push si
    mov si, cmd_buffer
.loop:
    mov al, [si]
    cmp al, 0
    je .done
    cmp al, 'A'
    jb .next
    cmp al, 'Z'
    ja .next
    add al, 20h
    mov [si], al
.next:
    inc si
    jmp .loop
.done:
    pop si
    pop ax
    ret

do_help:
    call clear_terminal_view
    mov si, help_screen
    call print_string
    ret

do_ver:
    mov si, version_screen
    call print_string
    ret

do_about:
    mov si, about_screen
    call print_string
    ret

do_cls:
    call reset_desktop
    ret

do_echo:
    mov si, cmd_buffer
    call skip_word
    call print_string
    call newline
    ret

do_color:
    mov si, cmd_buffer
    call skip_word
    cmp byte [si], '0'
    je .black
    cmp byte [si], '1'
    je .white
    mov si, color_help
    call print_string
    ret
.black:
    mov byte [text_color], COLOR_BLACK
    mov si, color_black_msg
    call print_string
    ret
.white:
    mov byte [text_color], COLOR_WHITE
    mov si, color_white_msg
    call print_string
    ret

do_prompt:
    mov si, cmd_buffer
    call skip_word
    cmp byte [si], 0
    je .reset
    mov di, prompt_custom
    mov cx, 15
.copy:
    lodsb
    cmp al, 0
    je .done
    stosb
    loop .copy
    mov al, 0
    stosb
.done:
    ret
.reset:
    mov byte [prompt_custom], 0
    ret

do_time:
    mov ah, 02h
    int 1Ah
    jc .error
    mov si, time_label
    call print_string
    mov al, ch
    call print_bcd
    mov al, ':'
    call print_char
    mov al, cl
    call print_bcd
    mov al, ':'
    call print_char
    mov al, dh
    call print_bcd
    call newline
    ret
.error:
    mov si, msg_rtc_error
    call print_string
    ret

do_date:
    mov ah, 04h
    int 1Ah
    jc .error
    mov si, date_label
    call print_string
    mov al, dl
    call print_bcd
    mov al, '/'
    call print_char
    mov al, dh
    call print_bcd
    mov al, '/'
    call print_char
    mov al, ch
    call print_bcd
    mov al, cl
    call print_bcd
    call newline
    ret
.error:
    mov si, msg_rtc_error
    call print_string
    ret

do_calc:
    mov si, cmd_buffer
    call skip_word
    call parse_decimal
    jc .error
    mov bx, ax
    call skip_spaces
    mov al, [si]
    cmp al, 0
    je .error
    cmp al, '+'
    je .add
    cmp al, '-'
    je .sub
    jmp .error
.add:
    inc si
    call parse_decimal
    jc .error
    mov cx, ax
    call skip_spaces
    cmp byte [si], 0
    jne .error
    mov ax, bx
    add ax, cx
    call print_number
    call newline
    ret
.sub:
    inc si
    call parse_decimal
    jc .error
    mov cx, ax
    call skip_spaces
    cmp byte [si], 0
    jne .error
    mov ax, bx
    cmp bx, cx
    jae .positive
    mov al, '-'
    call print_char
    mov ax, cx
    sub ax, bx
    call print_number
    call newline
    ret
.positive:
    sub ax, cx
    call print_number
    call newline
    ret
.error:
    mov si, calc_help
    call print_string
    ret

parse_decimal:
    push bx
    push dx
    call skip_spaces
    xor bx, bx
    mov al, [si]
    cmp al, '0'
    jb .bad
    cmp al, '9'
    ja .bad
.loop:
    mov al, [si]
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done
    sub al, '0'
    xor ah, ah
    push ax
    mov ax, bx
    mov dx, 10
    mul dx
    cmp dx, 0
    jne .overflow_pop
    mov bx, ax
    pop ax
    add bx, ax
    jc .bad_after_pop
    inc si
    jmp .loop
.overflow_pop:
    pop ax
    jmp .bad
.bad_after_pop:
    jmp .bad
.done:
    mov ax, bx
    pop dx
    pop bx
    clc
    ret
.bad:
    pop dx
    pop bx
    stc
    ret

do_mem:
    mov si, mem_screen
    call print_string
    mov ax, ds
    call print_hex_word
    call newline
    ret

do_beep:
    in al, 61h
    mov ah, al
    or al, 03h
    out 61h, al
    mov cx, 3000
.delay:
    loop .delay
    mov al, ah
    out 61h, al
    mov si, beep_msg
    call print_string
    ret

do_dir:
    mov si, dir_screen
    call print_string
    mov si, file_name_1
    call print_string
    mov si, file_size_1
    call print_string
    call newline
    mov si, file_name_2
    call print_string
    mov si, file_size_2
    call print_string
    call newline
    mov si, file_name_3
    call print_string
    mov si, file_size_3
    call print_string
    call newline
    mov si, dir_footer
    call print_string
    ret

do_type:
    mov si, cmd_buffer
    call skip_word
    mov di, file_key_1
    call string_equal
    jc .file1
    mov si, cmd_buffer
    call skip_word
    mov di, file_key_2
    call string_equal
    jc .file2
    mov si, cmd_buffer
    call skip_word
    mov di, file_key_3
    call string_equal
    jc .file3
    mov si, type_error
    call print_string
    ret
.file1:
    mov si, file_data_1
    call print_string
    call newline
    ret
.file2:
    mov si, file_data_2
    call print_string
    call newline
    ret
.file3:
    mov si, file_data_3
    call print_string
    call newline
    ret

do_write:
    mov si, msg_write
    call print_string
    ret

do_delete:
    mov si, msg_delete
    call print_string
    ret

do_info:
    mov si, info_screen
    call print_string
    ret

do_reboot:
    mov si, reboot_msg
    call print_string
    cli
    int 19h
    jmp 0FFFFh:0000h

do_shutdown:
    mov si, shutdown_msg
    call print_string
    mov ax, 5301h
    xor bx, bx
    int 15h
    mov ax, 530Eh
    xor bx, bx
    mov cx, 0102h
    int 15h
    mov ax, 5307h
    mov bx, 0001h
    mov cx, 0003h
    int 15h
.halt:
    cli
    hlt
    jmp .halt

do_game:
    mov si, game_title
    call print_string
    mov ah, 00h
    int 1Ah
    mov ax, dx
    xor dx, dx
    mov bx, 9
    div bx
    inc dl
    mov [game_a], dl
    mov ah, 00h
    int 1Ah
    mov ax, dx
    xor dx, dx
    mov bx, 9
    div bx
    inc dl
    mov [game_b], dl
    mov si, game_question
    call print_string
    mov al, [game_a]
    add al, '0'
    call print_char
    mov al, '+'
    call print_char
    mov al, [game_b]
    add al, '0'
    call print_char
    mov al, '='
    call print_char
    mov al, ' '
    call print_char
    call read_command
    mov si, cmd_buffer
    call parse_decimal
    jc .invalid
    mov bx, ax
    call skip_spaces
    cmp byte [si], 0
    jne .invalid
    xor ax, ax
    mov al, [game_a]
    xor ah, ah
    add al, [game_b]
    cmp bx, ax
    je .correct
    mov si, game_wrong
    call print_string
    ret
.invalid:
    mov si, game_invalid
    call print_string
    ret
.correct:
    mov si, game_correct
    call print_string
    ret

do_guess:
    mov si, guess_title
    call print_string
    mov si, guess_info
    call print_string
    call flush_keyboard
    mov ah, 00h
    int 1Ah
    mov ax, dx
    xor ax, cx
    xor dx, dx
    mov bx, 20
    div bx
    inc dx
    mov [guess_target], dx
    mov byte [guess_attempts], 0
.guess_loop:
    mov si, guess_prompt
    call print_string
    call read_command
    mov si, cmd_buffer
    call parse_decimal
    jc .invalid
    mov bx, ax
    call skip_spaces
    cmp byte [si], 0
    jne .invalid
    cmp bx, 1
    jb .invalid
    cmp bx, 20
    ja .invalid
    inc byte [guess_attempts]
    mov ax, bx
    cmp ax, [guess_target]
    je .correct
    ja .high
.low:
    mov si, guess_low
    call print_string
    jmp .check_attempts
.high:
    mov si, guess_high
    call print_string
.check_attempts:
    cmp byte [guess_attempts], 5
    jb .guess_loop
    mov si, guess_fail
    call print_string
    mov ax, [guess_target]
    call print_number
    call newline
    ret
.invalid:
    mov si, guess_invalid
    call print_string
    jmp .guess_loop
.correct:
    mov si, guess_correct
    call print_string
    mov al, [guess_attempts]
    xor ah, ah
    call print_number
    mov si, guess_attempts_msg
    call print_string
    ret

do_react:
    mov si, react_title
    call print_string
    mov si, react_info
    call print_string
    call flush_keyboard
    mov ah, 00h
    int 1Ah
    mov [react_start], dx
    mov ax, dx
    xor dx, dx
    mov bx, 55
    div bx
    add dx, 18
    mov [react_delay], dx
.wait_delay:
    mov ah, 01h
    int 16h
    jz .check_delay
    xor ah, ah
    int 16h
    cmp al, 27
    je .exit
    mov si, react_early
    call print_string
    ret
.check_delay:
    mov ah, 00h
    int 1Ah
    mov ax, dx
    sub ax, [react_start]
    cmp ax, [react_delay]
    jb .wait_delay
    mov si, react_go
    call print_string
    mov ah, 00h
    int 1Ah
    mov [react_start], dx
.wait_key:
    mov ah, 01h
    int 16h
    jz .wait_key
    xor ah, ah
    int 16h
    cmp al, 27
    je .exit
    mov ah, 00h
    int 1Ah
    mov ax, dx
    sub ax, [react_start]
    mov bx, 55
    mul bx
    mov si, react_result
    call print_string
    call print_number
    mov si, react_ms
    call print_string
.exit:
    ret

flush_keyboard:
.flush:
    mov ah, 01h
    int 16h
    jz .done
    xor ah, ah
    int 16h
    jmp .flush
.done:
    ret

draw_app_window:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    mov al, COLOR_BLACK
    mov bx, [app_x]
    mov dx, [app_y]
    mov cx, [app_w]
    mov bp, [app_h]
    call draw_rect
    mov al, COLOR_WHITE
    mov bx, [app_x]
    add bx, 2
    mov dx, [app_y]
    add dx, 2
    mov cx, [app_w]
    sub cx, 4
    mov bp, [app_h]
    sub bp, 4
    call fill_rect
    mov al, COLOR_BLACK
    mov bx, [app_x]
    add bx, 2
    mov dx, [app_y]
    add dx, 2
    mov cx, [app_w]
    sub cx, 4
    mov bp, 11
    call fill_rect
    mov si, app_title_buf
    xor cx, cx
.title_length:
    cmp byte [si], 0
    je .title_position
    inc si
    inc cx
    jmp .title_length
.title_position:
    mov ax, cx
    mov dx, CHAR_W
    mul dx
    mov bx, [app_w]
    sub bx, ax
    shr bx, 1
    add bx, [app_x]
    mov dx, [app_y]
    add dx, 4
    mov si, app_title_buf
    mov byte [draw_color], COLOR_WHITE
    call draw_string_at
    mov al, COLOR_WHITE
    mov bx, [app_x]
    add bx, 6
    mov dx, [app_y]
    add dx, 4
    mov cx, 7
    mov bp, 7
    call draw_rect
    mov al, COLOR_BLACK
    mov bx, [app_x]
    add bx, 8
    mov dx, [app_y]
    add dx, 6
    mov cx, 3
    mov bp, 3
    call fill_rect
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

app_restore_desktop:
    call reset_desktop
    ret

app_wait_key:
    call flush_keyboard
.wait:
    mov ah, 01h
    int 16h
    jz .wait
    xor ah, ah
    int 16h
    ret

do_finder:
    call draw_gui
    mov si, finder_title
    mov di, app_title_buf
    call copy_string
    mov word [app_x], 68
    mov word [app_y], 46
    mov word [app_w], 206
    mov word [app_h], 116
    call draw_app_window
    mov byte [draw_color], COLOR_BLACK
    mov si, finder_header
    mov bx, 79
    mov dx, 63
    call draw_string_at
    mov si, finder_1
    mov bx, 79
    mov dx, 80
    call draw_string_at
    mov si, finder_2
    mov bx, 79
    mov dx, 96
    call draw_string_at
    mov si, finder_3
    mov bx, 79
    mov dx, 112
    call draw_string_at
    mov si, finder_keys
    mov bx, 79
    mov dx, 136
    call draw_string_at
.finder_loop:
    call app_wait_key
    cmp al, 27
    je .exit
    cmp al, '1'
    je .file1
    cmp al, '2'
    je .file2
    cmp al, '3'
    je .file3
    jmp .finder_loop
.file1:
    mov si, file_data_1
    call finder_view_file
    jmp .finder_loop
.file2:
    mov si, file_data_2
    call finder_view_file
    jmp .finder_loop
.file3:
    mov si, file_data_3
    call finder_view_file
    jmp .finder_loop
.exit:
    call app_restore_desktop
    ret

finder_view_file:
    push si
    mov al, COLOR_WHITE
    mov bx, 72
    mov dx, 62
    mov cx, 198
    mov bp, 94
    call fill_rect
    mov byte [draw_color], COLOR_BLACK
    mov si, file_view_title
    mov bx, 82
    mov dx, 66
    call draw_string_at
    pop si
    mov bx, 82
    mov dx, 83
    call draw_wrapped_string_at
    mov si, file_view_back
    mov bx, 82
    mov dx, 130
    call draw_string_at
    ret

draw_wrapped_string_at:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    mov bp, bx
.next:
    lodsb
    cmp al, 0
    je .done
    cmp al, 13
    je .cr
    cmp al, 10
    je .lf
    call draw_char
    add bx, CHAR_W
    cmp bx, 250
    jb .next
    mov bx, bp
    add dx, CHAR_H+1
    jmp .next
.cr:
    mov bx, bp
.lf:
    add dx, CHAR_H+1
    jmp .next
.done:
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

do_notepad:
    call draw_gui
    mov si, notepad_title
    mov di, app_title_buf
    call copy_string
    mov word [app_x], 62
    mov word [app_y], 42
    mov word [app_w], 218
    mov word [app_h], 124
    call draw_app_window
    mov al, COLOR_WHITE
    mov bx, 69
    mov dx, 60
    mov cx, 204
    mov bp, 96
    call fill_rect
    mov byte [draw_color], COLOR_BLACK
    mov si, notepad_name
    mov bx, 76
    mov dx, 66
    call draw_string_at
    mov si, file_data_3
    mov bx, 76
    mov dx, 84
    call draw_wrapped_string_at
    mov si, notepad_hint
    mov bx, 76
    mov dx, 137
    call draw_string_at
    call app_wait_key
    call app_restore_desktop
    ret

draw_clock_data:
    push ax
    push bx
    push dx
    mov al, COLOR_WHITE
    mov bx, 78
    mov dx, 68
    mov cx, 184
    mov bp, 60
    call fill_rect
    mov byte [draw_color], COLOR_BLACK
    mov si, clock_label
    mov bx, 96
    mov dx, 76
    call draw_string_at
    mov ah, 02h
    int 1Ah
    jc .done
    mov al, ch
    mov bx, 100
    mov dx, 92
    call draw_bcd_at
    add bx, CHAR_W
    mov al, ':'
    call draw_char
    add bx, CHAR_W
    mov al, cl
    call draw_bcd_at
    add bx, CHAR_W
    mov al, ':'
    call draw_char
    add bx, CHAR_W
    mov al, dh
    call draw_bcd_at
    mov si, date_label
    mov bx, 96
    mov dx, 112
    call draw_string_at
    mov ah, 04h
    int 1Ah
    jc .done
    mov al, dl
    mov bx, 174
    mov dx, 112
    call draw_bcd_at
    add bx, CHAR_W
    mov al, '/'
    call draw_char
    add bx, CHAR_W
    mov al, dh
    call draw_bcd_at
    add bx, CHAR_W
    mov al, '/'
    call draw_char
    add bx, CHAR_W
    mov al, ch
    call draw_bcd_at
    add bx, CHAR_W
    mov al, cl
    call draw_bcd_at
.done:
    pop dx
    pop bx
    pop ax
    ret

draw_bcd_at:
    push ax
    push bx
    push dx
    mov ah, al
    shr al, 4
    add al, '0'
    call draw_char
    add bx, CHAR_W
    mov al, ah
    and al, 0Fh
    add al, '0'
    call draw_char
    pop dx
    pop bx
    pop ax
    ret

do_clock:
    call draw_gui
    mov si, clock_title
    mov di, app_title_buf
    call copy_string
    mov word [app_x], 70
    mov word [app_y], 46
    mov word [app_w], 200
    mov word [app_h], 102
    call draw_app_window
    call flush_keyboard
.clock_loop:
    call draw_clock_data
    mov ah, 01h
    int 16h
    jz .tick
    xor ah, ah
    int 16h
    cmp al, 27
    je .exit
    jmp .clock_loop
.tick:
    jmp .clock_loop
.exit:
    call app_restore_desktop
    ret

do_paint:
    call draw_gui
    mov si, paint_title
    mov di, app_title_buf
    call copy_string
    mov word [app_x], 54
    mov word [app_y], 42
    mov word [app_w], 250
    mov word [app_h], 128
    call draw_app_window
    mov al, COLOR_WHITE
    mov bx, 61
    mov dx, 60
    mov cx, 236
    mov bp, 94
    call fill_rect
    mov byte [draw_color], COLOR_BLACK
    mov si, paint_hint
    mov bx, 68
    mov dx, 62
    call draw_string_at
    mov word [paint_x], 150
    mov word [paint_y], 104
    call flush_keyboard
    call paint_cursor_toggle
.paint_loop:
    mov ah, 01h
    int 16h
    jnz .key_available
    jmp .mouse
.key_available:
    xor ah, ah
    int 16h
    cmp al, 0
    jne .not_extended
    jmp .mouse
.not_extended:
    cmp al, 27
    jne .not_escape
    jmp .exit
.not_escape:
    cmp al, 13
    jne .not_enter
    jmp .draw_point
.not_enter:
    or al, 20h
    cmp al, 'w'
    jne .check_s
    jmp .up
.check_s:
    cmp al, 's'
    jne .check_a
    jmp .down
.check_a:
    cmp al, 'a'
    jne .check_d
    jmp .left
.check_d:
    cmp al, 'd'
    jne .unknown_key
    jmp .right
.unknown_key:
    jmp .mouse
.up:
    call paint_cursor_toggle
    cmp word [paint_y], 79
    jbe .up_limit
    sub word [paint_y], 3
    jmp .up_show
.up_limit:
    mov word [paint_y], 76
.up_show:
    call paint_cursor_toggle
    jmp .paint_loop
.down:
    call paint_cursor_toggle
    cmp word [paint_y], 145
    jae .down_limit
    add word [paint_y], 3
    jmp .down_show
.down_limit:
    mov word [paint_y], 148
.down_show:
    call paint_cursor_toggle
    jmp .paint_loop
.left:
    call paint_cursor_toggle
    cmp word [paint_x], 67
    jbe .left_limit
    sub word [paint_x], 3
    jmp .left_show
.left_limit:
    mov word [paint_x], 64
.left_show:
    call paint_cursor_toggle
    jmp .paint_loop
.right:
    call paint_cursor_toggle
    cmp word [paint_x], 289
    jae .right_limit
    add word [paint_x], 3
    jmp .right_show
.right_limit:
    mov word [paint_x], 292
.right_show:
    call paint_cursor_toggle
    jmp .paint_loop
.draw_point:
    call paint_cursor_toggle
    call paint_commit_point
    call paint_cursor_toggle
    jmp .paint_loop
.mouse:
    cmp byte [mouse_enabled], 1
    je .mouse_available
    jmp .paint_loop
.mouse_available:
    mov ax, 03h
    int 33h
    test bx, 1
    jnz .mouse_pressed
    jmp .paint_loop
.mouse_pressed:
    cmp cx, 64
    jae .mouse_x_min_ok
    jmp .paint_loop
.mouse_x_min_ok:
    cmp cx, 294
    jbe .mouse_x_max_ok
    jmp .paint_loop
.mouse_x_max_ok:
    cmp dx, 76
    jae .mouse_y_min_ok
    jmp .paint_loop
.mouse_y_min_ok:
    cmp dx, 148
    jbe .mouse_y_max_ok
    jmp .paint_loop
.mouse_y_max_ok:
    call paint_cursor_toggle
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov di, ax
    mov ax, VIDEO_SEG
    mov es, ax
    mov byte [es:di], COLOR_BLACK
    inc di
    mov byte [es:di], COLOR_BLACK
    add di, 320
    mov byte [es:di], COLOR_BLACK
    inc di
    mov byte [es:di], COLOR_BLACK
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    call paint_cursor_toggle
    jmp .paint_loop
.exit:
    call paint_cursor_toggle
    call app_restore_desktop
    ret

paint_cursor_toggle:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    mov ax, [paint_y]
    mov bx, 320
    mul bx
    add ax, [paint_x]
    mov di, ax
    mov ax, VIDEO_SEG
    mov es, ax
    mov dx, 3
.row:
    mov cx, 3
.pixel:
    xor byte [es:di], 0Fh
    inc di
    loop .pixel
    add di, 317
    dec dx
    jnz .row
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

paint_commit_point:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    mov ax, [paint_y]
    mov bx, 320
    mul bx
    add ax, [paint_x]
    mov di, ax
    mov ax, VIDEO_SEG
    mov es, ax
    mov dx, 3
.row:
    mov cx, 3
.pixel:
    mov byte [es:di], COLOR_BLACK
    inc di
    loop .pixel
    add di, 317
    dec dx
    jnz .row
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

copy_string:
    push ax
.copy:
    lodsb
    stosb
    cmp al, 0
    jne .copy
    pop ax
    ret

string_equal:
    push ax
    push bx
    push si
    push di
.compare:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no
    cmp al, 0
    je .yes
    inc si
    inc di
    jmp .compare
.yes:
    pop di
    pop si
    pop bx
    pop ax
    stc
    ret
.no:
    pop di
    pop si
    pop bx
    pop ax
    clc
    ret

skip_word:
.skip:
    cmp byte [si], ' '
    je .found
    cmp byte [si], 0
    je .done
    inc si
    jmp .skip
.found:
    call skip_spaces
.done:
    ret

print_bcd:
    push ax
    mov ah, al
    shr al, 4
    add al, '0'
    call print_char
    mov al, ah
    and al, 0Fh
    add al, '0'
    call print_char
    pop ax
    ret

print_number:
    cmp ax, 0
    jne .convert
    mov al, '0'
    call print_char
    ret
.convert:
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide
.print:
    pop dx
    mov al, dl
    add al, '0'
    call print_char
    loop .print
    pop dx
    pop cx
    pop bx
    ret

print_hex_word:
    push ax
    push bx
    mov bx, ax
    mov al, bh
    call print_hex_byte
    mov al, bl
    call print_hex_byte
    pop bx
    pop ax
    ret

print_hex_byte:
    push ax
    mov ah, al
    shr al, 4
    call print_hex_digit
    mov al, ah
    and al, 0Fh
    call print_hex_digit
    pop ax
    ret

print_hex_digit:
    cmp al, 9
    jbe .number
    add al, 'A'-10
    jmp .print
.number:
    add al, '0'
.print:
    call print_char
    ret

startup_screen:
    db 'Bienvenido a 86a-DOS',13,10
    db 'Escritorio System 1 listo.',13,10
    db 'Escribe help para comandos.',13,10,13,10,0

ui_86a db '86a',0
ui_file db 'File',0
ui_edit db 'Edit',0
ui_view db 'View',0
ui_special db 'Special',0
ui_disk db 'Disk',0
ui_trash db 'Trash',0
ui_title db '86a-DOS',0
ui_ready db 'Terminal / LISTA',0
ui_resolution db 'VGA 320x200',0

prompt_default db '86a> ',0
prompt_custom times 16 db 0

cmd_help db 'help',0
cmd_ver db 'ver',0
cmd_about db 'about',0
cmd_cls db 'cls',0
cmd_clear db 'clear',0
cmd_echo db 'echo',0
cmd_color db 'color',0
cmd_prompt db 'prompt',0
cmd_time db 'time',0
cmd_date db 'date',0
cmd_calc db 'calc',0
cmd_mem db 'mem',0
cmd_beep db 'beep',0
cmd_dir db 'dir',0
cmd_type db 'type',0
cmd_write db 'write',0
cmd_del db 'del',0
cmd_info db 'info',0
cmd_reboot db 'reboot',0
cmd_shutdown db 'shutdown',0
cmd_game db 'game',0
cmd_guess db 'guess',0
cmd_react db 'react',0
cmd_finder db 'finder',0
cmd_paint db 'paint',0
cmd_clock db 'clock',0
cmd_notepad db 'notepad',0

help_screen:
    db 'COMANDOS DISPONIBLES',13,10
    db '--------------------',13,10
    db 'help ver about info mem',13,10
    db 'cls clear echo color prompt',13,10
    db 'time date calc beep dir',13,10
    db 'type write del reboot',13,10
    db 'shutdown game guess react',13,10
    db 'finder paint clock notepad',13,10
    db 'Paint: WASD move, ENTER draw, ESC close',13,10
    db '--------------------',13,10,0

version_screen:
    db '86a-DOS Version 2.7',13,10
    db 'Interface: Macintosh System 1 style',13,10
    db 'Video: VGA Mode 13h',13,10
    db 'Keyboard: BIOS INT 16h',13,10
    db 'Mouse: BIOS mouse driver via INT 33h',13,10,0

about_screen:
    db 'Micro86 Compact',13,10
    db '86a-DOS is a personal 16-bit operating system.',13,10
    db 'Graphical desktop with a monochrome classic GUI.',13,10
    db 'Simple. Fast. Beautiful. Yours.',13,10,0

info_screen:
    db 'SYSTEM INFO',13,10
    db 'CPU mode: 16-bit Real Mode',13,10
    db 'Video: VGA 320x200 256-color mode',13,10
    db 'GUI: monochrome System 1 inspired',13,10
    db 'Keyboard: BIOS INT 16h',13,10
    db 'RTC: BIOS INT 1Ah',13,10
    db 'Mouse: INT 33h when available',13,10,0

mem_screen db 'Current segment: 0x',0
color_help db 'Use color 0 for black or color 1 for white.',13,10,0
color_black_msg db 'Text color set to black.',13,10,0
color_white_msg db 'Text color set to white.',13,10,0
clear_screen_msg db 0
beep_msg db 'Beep sent.',13,10,0
time_label db 'Hora actual: ',0
date_label db 'Fecha actual: ',0
calc_help db 'Usage: calc 10+5, calc 50-12, calc 20 - 4',13,10,0

dir_screen db 'Volume: 86A-DOS',13,10,'Directory of A:\',13,10,0
file_name_1 db 'KERNEL.SYS',0
file_size_1 db ' 16384 bytes',0
file_name_2 db 'COMMAND.COM',0
file_size_2 db ' 8192 bytes',0
file_name_3 db 'README.TXT',0
file_size_3 db ' 1024 bytes',0
dir_footer db '3 File(s)',13,10,0
file_key_1 db 'kernel.sys',0
file_key_2 db 'command.com',0
file_key_3 db 'readme.txt',0

file_data_1 db '86aKERN graphical kernel online.',13,10,'Memory services online.',13,10,'Video services online.',13,10,'Keyboard services online.',13,10,0
file_data_2 db '86a-SHELL command processor.',13,10,'Status: ONLINE',13,10,0
file_data_3 db 'Welcome to 86a-DOS.',13,10,'This computer belongs to you.',13,10,0

msg_bad_command db 'Comando no encontrado. Escriba help.',13,10,0
msg_rtc_error db 'RTC unavailable.',13,10,0
type_error db 'File not found.',13,10,0
msg_write db 'WRITE: RAMFS editor interface reserved for the next release.',13,10,0
msg_delete db 'DEL: protected system files cannot be deleted.',13,10,0
reboot_msg db '86a-DOS: rebooting...',13,10,0
shutdown_msg db '86a-DOS: shutting down...',13,10,0

game_title db 'MATHLOCK',13,10,0
game_question db 'Solve: ',0
game_correct db 'Correct!',13,10,0
game_wrong db 'Wrong answer.',13,10,0
game_invalid db 'Respuesta invalida.',13,10,0

guess_title db 'ADIVINA EL NUMERO',13,10,0
guess_info db 'Adivina un numero entre 1 y 20. Tienes 5 intentos.',13,10,0
guess_prompt db 'Numero: ',0
guess_low db 'Demasiado bajo: prueba un numero MAYOR.',13,10,0
guess_high db 'Demasiado alto: prueba un numero MENOR.',13,10,0
guess_correct db 'Correcto en ',0
guess_attempts_msg db ' intento(s).',13,10,0
guess_fail db 'Se acabaron los intentos. Era ',0
guess_invalid db 'Valor invalido. Usa un numero de 1 a 20.',13,10,0

react_title db 'REFLEJOS',13,10,0
react_info db 'Espera a GO! y pulsa cualquier tecla. ESC sale.',13,10,0
react_go db 'GO! ',0
react_early db 'Demasiado pronto.',13,10,0
react_result db 'Tiempo: ',0
react_ms db ' ms',13,10,0


finder_title db 'Finder',0
finder_header db 'A:\',0
finder_1 db '1 KERNEL.SYS',0
finder_2 db '2 COMMAND.COM',0
finder_3 db '3 README.TXT',0
finder_keys db '1-3 OPEN  ESC CLOSE',0
file_view_title db 'File viewer',0
file_view_back db 'Press any key to return',0
notepad_title db 'Notepad',0
notepad_name db 'README.TXT',0
notepad_hint db 'Press any key to close',0
clock_title db 'Clock',0
clock_label db 'Current time',0
paint_title db 'Paint',0
paint_hint db 'WASD: move  ENTER: draw  ESC: close',0

app_title_buf times 32 db 0
app_x dw 0
app_y dw 0
app_w dw 0
app_h dw 0
paint_x dw 150
paint_y dw 104

game_a db 0
game_b db 0
guess_target dw 0
guess_attempts db 0
react_start dw 0
react_delay dw 0
text_color db COLOR_BLACK
prompt_color db COLOR_BLACK
draw_color db COLOR_BLACK
mouse_enabled db 0
font_off dw 0
font_seg dw 0
text_x dw TERM_LEFT
text_y dw TERM_TOP
input_start_x dw TERM_LEFT
input_y dw TERM_TOP
rect_color db 0
rect_x dw 0
rect_y dw 0
rect_w dw 0
rect_h dw 0
saved_char db 0
saved_input_char db 0
saved_color db 0
cursor_tick dw 0
cursor_state db 0
cursor_visible db 0
input_len db 0
cmd_buffer times CMD_SIZE db 0

kernel_end:
kernel_size equ kernel_end - $$
kernel_sectors equ (kernel_size + 511) / 512
times kernel_sectors * 512 - (kernel_end - $$) db 0
