; ============================================================================
; THINK OS - STAGE 1 BOOTLOADER (FIXED)
; ============================================================================
; This is the first 512 bytes that gets loaded by BIOS
; Its only job is to load Stage 2 from disk
; ============================================================================
; Build: nasm -f bin stage1.asm -o stage1.bin
; ============================================================================

[BITS 16]
[ORG 0x7C00]

STAGE2_SEGMENT equ 0x1000
STAGE2_OFFSET equ 0x0000
STAGE2_SECTORS equ 64        ; Load 64 sectors (32KB for Stage 2)

start:
    ; Setup segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; IMPORTANT: Save boot drive from BIOS (in DL)
    mov [boot_drive], dl

    ; Clear screen and set video mode
    mov ax, 0x0003
    int 0x10

    ; Display boot logo
    mov si, logo1
    call print
    mov si, logo2
    call print
    mov si, logo3
    call print
    mov si, logo4
    call print
    mov si, logo5
    call print
    call newline

    ; Display loading message
    mov si, msg_loading
    call print

    ; Load Stage 2 from disk
    call load_stage2

    ; Display success
    mov si, msg_success
    call print
    call newline

    ; Small delay for effect
    mov cx, 0xFFFF
.delay:
    nop
    loop .delay

    ; Jump to Stage 2
    mov si, msg_starting
    call print
    
    ; IMPORTANT: Pass boot drive to Stage 2 in DL
    mov dl, [boot_drive]
    
    ; Jump to loaded code
    jmp STAGE2_SEGMENT:STAGE2_OFFSET

; ============================================================================
; LOAD STAGE 2 FROM DISK
; ============================================================================
load_stage2:
    pusha
    
    ; Reset disk system (use actual boot drive)
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; Load Stage 2
    ; AH = 0x02 (read)
    ; AL = number of sectors
    ; CH = cylinder
    ; CL = sector (starts at 2, after boot sector)
    ; DH = head
    ; DL = drive
    ; ES:BX = buffer

    mov ax, STAGE2_SEGMENT
    mov es, ax
    xor bx, bx          ; ES:BX = STAGE2_SEGMENT:0

    mov ah, 0x02        ; Read function
    mov al, STAGE2_SECTORS
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2 (sector after boot sector)
    mov dh, 0           ; Head 0
    mov dl, [boot_drive] ; Use actual boot drive
    int 0x13
    
    jc disk_error

    ; Show progress dots
    mov si, dot
    call print
    
    popa
    ret

disk_error:
    mov si, msg_error
    call print
    call newline
    mov si, msg_error2
    call print
    
    ; Show which drive failed
    mov si, msg_drive
    call print
    mov al, [boot_drive]
    call print_hex
    call newline
    
    cli
    hlt

; ============================================================================
; HELPER FUNCTIONS
; ============================================================================

; Print string (SI = address)
print:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

; Print newline
newline:
    pusha
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    popa
    ret

; Print byte in AL as hex
print_hex:
    pusha
    mov ah, 0x0E
    
    ; High nibble
    mov bl, al
    shr al, 4
    cmp al, 9
    jle .high_digit
    add al, 7
.high_digit:
    add al, '0'
    int 0x10
    
    ; Low nibble
    mov al, bl
    and al, 0x0F
    cmp al, 9
    jle .low_digit
    add al, 7
.low_digit:
    add al, '0'
    int 0x10
    
    popa
    ret

; ============================================================================
; DATA
; ============================================================================

boot_drive  db 0

logo1       db '  _____ _   _ ___ _   _ _  __', 13, 10, 0
logo2       db ' |_   _| |_| |_ _| |_| | |/ /', 13, 10, 0
logo3       db '   | | |  _  || ||  _  |   < ', 13, 10, 0
logo4       db '   |_| |_| |_|___|_| |_|_|\_\', 13, 10, 0
logo5       db '         OS v1.3.0 FIXED', 13, 10, 0   

msg_loading db 'Loading kernel', 0
msg_success db ' OK!', 13, 10, 0
msg_starting db 'Starting Think OS...', 13, 10, 0
msg_error   db 13, 10, 'DISK READ ERROR!', 0
msg_error2  db 'Cannot load Stage 2', 13, 10, 0
msg_drive   db 'Boot drive: 0x', 0
dot         db '.', 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55