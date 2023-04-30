; simple file system MDTFS
;   txt - text file
;   mdt - executable binary

print_filelist:
    call load_filatable
    mov si, fileheader
    call print_string
    xor cx, cx
    mov ax, 0100h
    mov ds, ax
    xor si, si
.print_fileloop:
    lodsb
    cmp cx, 9
    je .print_ext
    cmp al, 0
    je .print_sector
    mov ah, 0Eh
    int 10h
    inc cx
    jmp .print_fileloop
.print_ext:
    cmp cx, 14
    je .print_fileloop
    mov ah, 0Eh
    mov al, ' '
    int 10h
    inc cx
    jmp .print_ext
.print_sector:
    cmp cx, 28
    je .1
    mov ah, 0Eh
    mov al, ' '
    int 10h
    inc cx
    jmp .print_sector
.1:
    lodsb
    call print_hexbyte
.print_size:
    cmp cx, 40
    je .2
    mov ah, 0Eh
    mov al, ' ' 
    int 10h
    inc cx
    jmp .print_size
.2:
    lodsb 
    call print_hexbyte
.next_file:
    xor cx, cx
    mov ax, 0E0Ah
    int 10h
    mov ax, 0E0Dh
    int 10h
    lodsb 
    cmp al, 0x0
    je .stop
    dec si
    jmp .print_fileloop
.stop:
    mov ax, 0200h
    mov ds, ax
    mov es, ax
    mov ax, 0E0Ah
    int 10h
    mov ax, 0E0Dh
    int 10h
    ret   

load_file_start:
    mov si, msg_searchfile
    call print_string
    
    call load_filatable
    mov ax, 0100h
    mov ds, ax
    mov di, cmd_str
    xor cx, cx
    mov byte [cmd_strctr], 0
.start_getname:
    call get_keystroke 
    mov ah, 0Eh
    cmp al, 0Dh
    je set_search
    int 10h
    mov [di], al
    inc byte [cmd_strctr]
    inc di
    jmp .start_getname
set_search:
    xor si, si
    mov cl, byte [cmd_strctr]
.search_program:
    mov al, [si]
    inc si
    cmp al, [di]
    jne .program_nextsearch
    dec cl
    jz .program_found
    inc di
    jmp .search_program
.program_nextsearch:
    cmp byte [si], 0
    je .check_again
    inc si
    jmp .program_nextsearch
.check_again:
    mov di, cmd_str
    add si, 3
    cmp byte [si], 0
    je .program_notfound
    jmp .search_program
.program_notfound:
    mov ax, 0200h
    mov es, ax 
    mov ds, ax 
    mov si, msg_failsearch
    call print_string
    ret 
.program_found:   
    mov cl, 10
    sub cl, byte [cmd_strctr]
.loop:
    dec cl
    jz .save_ext
    inc si
    jmp .loop
.save_ext:
    inc si
    mov al, [si]
    mov [ext], al
    inc si
    mov al, [si]
    mov [ext + 1], al
    inc si
    mov al, [si]
    mov [ext + 2], al
    inc si
.load_program:
    mov cx, 3
    push si
    mov si, ext
    mov ax, 0200h
    mov es, ax
    mov di, mdt_ext
    repe cmpsb
    jne txt_ext_handle
    pop si

    inc si
    mov dl, es:[boot_disk]
    mov ax, 0800h       ; load program memory segment
    mov es, ax
    mov bx, 0
    mov cl, [si]
    inc si 
    mov al, [si]        ; for test  
    call disk_load_sector
.run_prog:
    mov ax, 0800h
    mov es, ax
    mov ds, ax
    jmp 0800h:0000h     ; jump to program memory

    mov ax, 0200h
    mov es, ax
    mov ds, ax
    mov si, msg_failload
    call print_string
    ret 

txt_ext_handle:
    mov cx, 3
    mov si, ext
    mov ax, 0200h
    mov es, ax
    mov di, txt_ext
    repe cmpsb
    jne .ext_fail
.load_txt_file:
    pop si
    inc si
    mov dl, es:[boot_disk]
    mov ax, 0800h
    mov es, ax
    mov bx, 0
    mov cl, [si]
    inc si
    mov al, [si]
    call disk_load_sector

    mov ax, 0800h
    mov es, ax
    mov ds, ax
    xor si, si
    mov ah, 0Eh
    mov ax, 0E0Ah
    int 10h
    mov ax, 0E0Dh
    int 10h
    mov ax, 0E0Ah
    int 10h
    mov ax, 0E0Dh
    int 10h
.print_txt:
    lodsb
    cmp al, 0
    je .stop_txtloop
    int 10h
    jmp .print_txt
.stop_txtloop:
    mov ax, 0200h
    mov es, ax
    mov ds, ax
    ret
.ext_fail:
    pop si
    mov ax, 0200h
    mov es, ax 
    mov ds, ax 
    mov si, msg_extfail
    call print_string
    ret 

load_filatable: 
    mov ax, 0100h
    mov es, ax
    mov bx, 0
    mov cl, 0Ah
    mov dl, [boot_disk]
    mov al, 1
    call disk_load_sector
    ret

ext:        db "   ",0
mdt_ext:    db "mdt",0
txt_ext:    db "txt",0
