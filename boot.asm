    org 7C00h

start:
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax 
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ax, 7C00h
    mov sp, ax
    sti

    mov si, msg_load
    call print_string

    ; load kernel 
    mov bx, 2000h

    ; int 13h params
    mov dh, 0
    mov dl, 0
    
read_sector1:
    mov ah, 02h
    mov al, 6
    mov ch, 0
    mov cl, 2
    int 0x13
    jc read_sector1

run_kernel:
    mov ax, 0200h
    mov ds, ax 
    mov es, ax
    mov ss, ax

    mov ax, 0FFFFh
    mov sp, ax

    mov al, 0DEh
    jmp 0200h:0000h    ; jump to kernel

print_string:
    pusha
    mov ah, 0Eh
    mov bh, 0

    .loop:
        lodsb
        cmp al, 0
        je .end
        int 10h
        jmp .loop

    .end:
        popa
        ret 

    jmp $

msg_load:
    db "Loading...", 0Ah, 0Dh, 0
msg_err:
    db "Err load disk :(", 0Dh, 0Ah, "Trying again...", 0Ah, 0Dh, 0

    times 510-($-$$) db 0 
    dw 0AA55h
