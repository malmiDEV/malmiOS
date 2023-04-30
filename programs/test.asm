main:
    mov ax, 0003h
    int 0x10

    mov ax, 0B800h
    mov es, ax

    mov ax, 3F20h
    mov di, 0
    mov cx, 80*25
    rep stosw

    mov si, msg_test
    call print_string
    call get_keystroke

.close:
    mov ax, 0200h
    mov es, ax
    mov ds, ax
    mov al, 0ADh
    jmp 0200h:0000h

    %include "include/input.asm"
    %include "include/string.asm"

msg_test:
    db "test program loaded!", 0ah, 0dh, "press any key to close program...", 0

    times 512-($-$$) db 0