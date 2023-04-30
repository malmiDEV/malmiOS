disk_load_sector:
    mov ch, 0
    mov dh, 0

    mov ah, 02h
    int 13h
    jc .error

    ret

.error:
    mov si, readerror
    call print_string

.halt:
    cli
    hlt

readerror: db "Read Sector Error :<", 0