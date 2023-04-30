quick_check:
    cmp al, 0DEh
    je .from_bootsectrun
    cmp al, 0ADh
    je .from_returnsomwhererun

    call panic_screen
    mov si, msg_panic
    call print_string
    jmp $               ; just stop
.from_bootsectrun:
    xor ax, ax
    mov [boot_disk], dl
    call clear_screen
    mov si, welcome
    call print_string
    mov si, prompt
    call print_string
    jmp get_input
.from_returnsomwhererun:
    xor ax, ax
    jmp kernel_wait

kernel_wait:
    call clear_screen
    mov si, prompt
    call print_string
    jmp get_input

backto_promt:
    mov si, prompt
    call print_string
get_input:  
    mov di, cmd_str
.loop:
    call get_keystroke
    mov ah, 0Eh
    cmp al, 0Dh
    je run_command
    int 10h
    mov [di], al
    inc di
    jmp .loop

run_command:
    mov byte [di], 0
    
    push word cmd_str
    push word rip_cmd
    call strcmp
    cmp al, 0
    je cmd_rip

    push word cmd_str
    push word dir_cmd
    call strcmp
    cmp al, 0
    je cmd_dir
    
    push word cmd_str
    push word loadfile_cmd
    call strcmp
    cmp al, 0 
    je cmd_loadfile

    push word cmd_str
    push word cls_cmd
    call strcmp
    cmp al, 0
    je cmd_cls
    
    push word cmd_str
    push word reboot_cmd
    call strcmp
    cmp al, 0
    je cmd_reboot

    push word cmd_str
    push word shutdown_cmd
    call strcmp
    cmp al, 0
    je cmd_shutdown

    push word cmd_str
    push word hello_cmd
    call strcmp
    cmp al, 0
    je cmd_hello
  
    push word cmd_str
    push word sysinfo_cmd
    call strcmp
    cmp al, 0
    je cmd_sysinfo

    push word cmd_str
    push word help_cmd
    call strcmp
    cmp al, 0
    je cmd_help
    
    mov si, msg_notfound
    call print_string
    mov si, prompt
    call print_string
    jmp get_input

cmd_rip:    
    call clear_screen
    mov si, msg_unga
    call print_string

    call get_keystroke
    jmp backto_promt

cmd_dir:
    call print_filelist
    jmp backto_promt

cmd_loadfile:
    call load_file_start
    jmp backto_promt

cmd_cls:
    call clear_screen
    jmp backto_promt

cmd_reboot:
    jmp 0FFFFh:0000h

; only for qemu not on real hardware :<
cmd_shutdown:
    mov dx, 604h
    mov ax, 2000h
    out dx, ax

cmd_hello:
    mov si, msg_hello
    call print_string
    jmp backto_promt

cmd_sysinfo:
    mov si, msg_sysinfo
    call print_string
    jmp backto_promt

cmd_help:
    mov si, msg_help
    call print_string
    jmp backto_promt

.loop:
    jmp $

%include "include/screen.asm"
%include "include/string.asm" 
%include "include/input.asm"
%include "include/load_sector.asm"
%include "include/hex.asm"
%include "include/mdtfs.asm"

%define nl 0Ah, 0Dh

rip_cmd:        db "rip",0
dir_cmd:        db "dir",0
loadfile_cmd:   db "load",0
cls_cmd:        db "cls",0
reboot_cmd:     db "reboot",0
shutdown_cmd:   db "shutdown",0
hello_cmd:      db "hello",0
help_cmd:       db "help",0
sysinfo_cmd:    db "sysinfo",0

cmd_str: 
    resb 60
cmd_strctr:
    db 0

boot_disk:
    db 0

welcome:
    db "------------------------------", nl, \
       "    MALMI OS KERNEL BOOTED    ", nl, \
       "------------------------------", nl,nl, 0
prompt: 
    db "READY.",nl,"@ ",0
fileheader:
    db nl,nl,\
        "----------    ----------    ----------    ----------", nl, \
        "   NAME          EXTN         SECTOR         SIZE   ", nl, \
        "----------    ----------    ----------    ----------", nl, 0
msg_sysinfo:
    db nl,nl,\
        "-----------MALMI OS PROTOTYPE---------",nl,\
        " KERNEL - MalmiOS Kernel 1.0",nl,\
        " CPU MODE - 16Bit Real Mode",nl,\
        " BOOT - Legacy Bios Boot (0xAA55)",nl,\
        " FILE SYS - MDTFS File System",nl,\
        " FILE TABLE FORMAT - MDTFT File Table",nl,\
        " BOOT DRIVE - IDK",nl,\
        "--------------------------------------",nl,nl,0
msg_help:
    db nl,nl,\
        "rip     - rest in peace, s. ung-a.", nl,\
        "dir     - open file manager", nl,\
        "cls     - clear screen", nl, \
        "reboot  - warm reboot your computer", nl,\
        "hello   - print (Hello, World!)", nl,\
        "sysinfo - show info about operating system",nl,\
        "help    - print prompt command list", nl,nl, 0
msg_hello:
    db nl,nl,"Hello, World!",nl,nl, 0
msg_unga:
    db nl,nl, \
        "    REST IN PEACE.", nl, \
        "      2013-2022  ", nl, \
        "  But, Life Goes On.", nl, 0
msg_foundprog:
    db nl,nl,"Loading program to: 0x0800:0x0000",nl,nl,0
msg_notfound:
    db nl,nl,"?Command not found.",nl,0
msg_panic:
    db "KERNEL PANIC!", nl, 0
msg_searchfile:
    db nl,nl,"Enter the filename to execute",nl,"-> ",0 
msg_failsearch:
    db nl,nl,"Cannot find your program",nl,nl,0
msg_failload:
    db nl,nl,"Program founded but system cannot execute",nl,nl,0
msg_extfail:
    db nl,nl,"This File Format does not supported",nl,nl,0

    times 4096-($-$$) db 0
