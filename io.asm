;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ FILES, WRITE FILES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global _start                   ; entry point

segment .data
    ; === SYSCALL SYMBOLS ===
    sys_read   equ   0x0        ; 0
    sys_write  equ   0x1        ; 1
    sys_open   equ   0x2        ; 2
    sys_close  equ   0x3        ; 3
    sys_exit   equ   0x3C       ; 60
    ; === SYS_OPEN FLAGS ===
    o_rdonly   equ   0x0        ; read only
    o_wronly   equ   0x1        ; write only
    o_rdwr     equ   0x02       ; read and write
    o_create   equ  0x100       ; create if not exists
    o_excl     equ  0x200       ; signal "failure" if file already exists
    o_truncate equ  0x400       ; truncate to 0
    o_append   equ  0x800       ; append to file
    o_nonblock equ  0x1000      ; non blocking mode
    o_sync     equ  0x2000      ; write in sync mode
    o_dsync    equ  0x4000      ; write sync, but not m-data
    o_rsync    equ  0x8000      ; read sync mode
    o_noctty   equ  0x10000     ; no controlling terminal
    o_nofollow equ  0x20000     ; no follow symlinks
    o_clexec   equ  0x40000     ; close fd on exec
    o_dir      equ  0x80000     ; fail if not directory

    ; === SYS_OPEN PROTECTION MODE ===
    s_irusr    equ  0x100       ; read permissions for owner
    s_iwusr    equ  0x80        ; write permissions for owner
    s_ixusr    equ  0x40        ; execute permission for owner
    s_irgrp    equ  0x20        ; read permission for group
    s_iwgrp    equ  0x10        ; write permission for the group
    s_ixgrp    equ  0x8         ; execute permission for group
    s_iroth    equ  0x4         ; read permission for others
    s_iwoth    equ  0x2         ; write permission for others
    s_ixoth    equ  0x1         ; execute permission for others

    ; === STREAM DIRECTION ===
    stin       equ  0b00000000  ; 0(standard in), for stdin
    stout      equ  0b00000001  ; 1(standard out), for stdout
    ; === General ===
    _fst_      equ  0b00010000  ; file size threshold, will not read below this value
    _pm_       db   "Enter fileName: ", 0x0
    _pms_      equ  $ - _pm_

segment .bss 
    _fn_       resb 0b00010000  ; max 16 bytes for filename

%macro SRO 2                    ; [1=buffer;2=size]
    mov  rax, sys_write         ; write syscall
    mov  rdi, stout             ; standard output code
    lea  rsi, %1                ; load address of string
    mov  rdx, %2                ; load size of string
    syscall 
%endmacro

%macro SRI 2                    ; [1=buffer;2=size]
    mov  rax, sys_read          ; read syscall
    mov  rdi, stin              ; for reading
    mov  rsi, %1                ; buffer
    mov  rdx, %2                ; buffer size
    syscall
%endmacro

%macro FD_Open 1                ; [1=filename], returns new fd in RAX
    mov  rsi, o_rdwr  | o_truncate 
    mov  rdx, s_irusr | s_iwusr    | s_irgrp | s_iroth
    mov  rax, sys_open          ; for fd open
    mov  rdi, %1                ; filename 1000 0010
    syscall
%endmacro

%macro FD_Valid 1               ; [1=FD]
    cmp   %1,  0x3
    _CJ1:
        mov rax, 0x1
        jmp _CJL
    _CJ2:
        mov rax, 0x0
        jmp _CJL
    _CJL:
        call  __EZfdvalid
%endmacro

%macro FD_Close 1        ; [1=FD]
    mov  rax, sys_close  ; close f-descriptor
    mov  rdi, %1         ; file descriptor
    syscall
%endmacro

segment .text

_start:
    SRO       _pm_, _pms_  ; prompt msg
    SRI       _fn_, _fst_  ; read input
    FD_Open   _fn_         ; open file descriptor
    FD_Valid  rax          ; verify fd state
    FD_Close  rax          ; close f-descriptor



__EZexit:
    mov  rax, sys_exit   ; exit program
    xor  rdi, rdi        ; xor(reset) return value
    syscall
__EZfdvalid:
    jmp __EZexit
    ret
