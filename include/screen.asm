clear_screen:   
    pusha

    mov ax, 0003h
    int 10h

    mov ah, 0Bh
    mov bh, 0
    mov bl, 01h
    int 10h

    popa
    ret

panic_screen:
    pusha

    mov ax, 0x0003
    int 10h

    mov ah, 0Bh
    mov bh, 0
    mov bl, 04h
    int 10h
    
    popa 
    ret
