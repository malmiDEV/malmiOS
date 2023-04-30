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

strlen: 
    xor cx,cx
    push si
.loop:
    lodsb
    cmp al, 0  
    je .1
    inc cx
    jmp .loop
.1:
    pop si
    ret

; for fun use call convension
strcmp:
    push bp             ; save previous call frame
    mov bp, sp
    push si
    push di

    mov si, [bp + 4]    ; first parameter (str1)
    mov di, [bp + 6]    ; second parameter (str2)
.loop:                  ; you know that...
    mov al, [si]        
    mov bl, [di]

    cmp al, bl          
    jne .done           
    cmp al, 0
    je .eq
    cmp bl, 0
    je .eq
    inc si
    inc di
    jmp .loop
.eq:
    mov ax, 0
    jmp .stop
.done:
    mov ax, 1
.stop:
    pop di              ; pop and restore registers
    pop si
    pop bp
    ret                 