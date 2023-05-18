;; MDTFT 
;; ------
;; file name: string (9 byte)
;; extension: string (3 byte)
;; null byte: hex (1 byte)
;; sector pos: hex (1 byte)
;; sector count: hex (1 byte)
;;
;; file name(9 byte) + extension(3 byte) = 12byte for string data
;; each single element in disk has 16 byte for filedata
;; maximun size for 1 element 00h~FFh (0 ~ 255) 127.5kb
;; maximum file size for entire disk is 31.7505~ mb
;; 
;;
;; after extension must be 1 byte padd  

    db "kernel    mdt", 0, 02h, 06h
    db "filetable txt", 0, 0Ah, 01h
    db "test      mdt", 0, 0Bh, 01h
    db "malmi     txt", 0, 0Ch, 01h
    db "ext_fail  abc", 0, 0DEh, 0ADh

    ; sector padd 
    times 512-($-$$) db 0
