    ; 0x30-0x39 = '0'~'9' ascii value
print_hexchar:
    add al, 30h
    cmp al, 39h
    jle .stop
    add al, 07h    ; get 'A'~'F' ascii value
.stop:
    mov ah, 0Eh
    int 10h
    ret

print_hexbyte:
    push ax
    shr al, 4
    call print_hexchar
    pop ax

    push ax 
    and al, 0Fh
    call print_hexchar
    pop ax
    ret
