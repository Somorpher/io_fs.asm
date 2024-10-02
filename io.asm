;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ FILES, WRITE FILES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global _start                   ; entry point

segment .data
    ; === SYSCALL SYMBOLS ===
    sys_read   equ  0x00000000  ; 0
    sys_write  equ  0x00000001  ; 1
    sys_open   equ  0x00000002  ; 2
    sys_close  equ  0x00000003  ; 3
    sys_exit   equ  0x0000003C  ; 60
    sys_mmap   equ  0x00000009  ; 9
    sys_unmap  equ  0x0000000B  ; 11
    ; === SYS_OPEN FLAGS ===
    o_rdonly   equ  0x00000000  ; read only
    o_wronly   equ  0x00000001  ; write only
    o_rdwr     equ  0x00000002  ; read and write
    o_create   equ  0x00000100  ; create if not exists
    o_excl     equ  0x00000200  ; signal "failure" if file already exists
    o_truncate equ  0x00000400  ; truncate to 0
    o_append   equ  0x00000800  ; append to file
    o_nonblock equ  0x00001000  ; non blocking mode
    o_sync     equ  0x00002000  ; write in sync mode
    o_dsync    equ  0x00004000  ; write sync, but not m-data
    o_rsync    equ  0x00008000  ; read sync mode
    o_noctty   equ  0x00010000  ; no controlling terminal
    o_nofollow equ  0x00020000  ; no follow symlinks
    o_clexec   equ  0x00040000  ; close fd on exec
    o_dir      equ  0x00080000  ; fail if not directory
    ; === SYS_OPEN PROTECTION MODE ===
    s_irusr    equ  0x00000100  ; read permissions for owner
    s_iwusr    equ  0x00000080  ; write permissions for owner
    s_ixusr    equ  0x00000040  ; execute permission for owner
    s_irgrp    equ  0x00000020  ; read permission for group
    s_iwgrp    equ  0x00000010  ; write permission for the group
    s_ixgrp    equ  0x00000008  ; execute permission for group
    s_iroth    equ  0x00000004  ; read permission for others
    s_iwoth    equ  0x00000002  ; write permission for others
    s_ixoth    equ  0x00000001  ; execute permission for others
    ; === STREAM DIRECTION ===
    stin       equ  0b00000000  ; 0(standard in), for stdin
    stout      equ  0b00000001  ; 1(standard out), for stdout
    ; === General ===
    _tdir_      db   '/home/user/code/asm/test-dir' ; target directory
    _fst_       equ  0b00010000  ; file size threshold, will not read below this value
    _pm_        db   0x45,0x6E,0x74,0x65,0x72,0x20                   ; 'Enter fileName: ', 0
                db   0x66,0x69,0x6C,0x65,0x4E,0x61
                db   0x6D,0x65,0x3A,0x20,0x0a,0x0d, 0x0  
    _pms_       equ  $ - _pm_    
    _enocase    db   0x55, 0x6E, 0x6B, 0x6E, 0x6F, 0x77, 0x6E, 0x20  ; 'Unknown error!'
                db   0x65, 0x72, 0x72, 0x6F, 0x72, 0x21, 0x00   
    _enocase_sz equ  $ - _enocase
    _enoent     db   0x45, 0x4E, 0x4F, 0x45, 0x4E, 0x54, 0x3A, 0x20   ; ENOENT: No Such File or Directory
                db   0x4E, 0x6F, 0x20, 0x53, 0x75, 0x63, 0x68
                db   0x20, 0x46, 0x69, 0x6C, 0x65, 0x20, 0x6F
                db   0x72, 0x20, 0x44, 0x69, 0x72, 0x65, 0x63
                db   0x74, 0x6F, 0x72, 0x79, 0x21, 0x0a, 0x0d
                db   0x00
    _enoent_sz  equ  $ - _enoent
    _eexist     db   0x45, 0x45, 0x58, 0x49, 0x53, 0x54, 0x3A, 0x20   ; EEXIST: File Exists
                db   0x46, 0x69, 0x6C, 0x65, 0x20, 0x45, 0x78
                db   0x69, 0x73, 0x74, 0x73, 0x21, 0x0a, 0x0d
                db   0x00
    _eexist_sz  equ  $ - _eexist
    _enotdir    db   0x45, 0x4E, 0x4F, 0x54, 0x44, 0x49, 0x52, 0x3A   ; ENOTDIR: Not Directory!
                db   0x20, 0x4E, 0x6F, 0x74, 0x20, 0x44, 0x69, 0x72
                db   0x65, 0x63, 0x74, 0x6F, 0x72, 0x79, 0x21,0x0a, 0x0d, 0x00
    _enotdir_sz equ  $ - _enotdir
    _eisdir     db   0x45, 0x49, 0x53, 0x44, 0x49, 0x52, 0x3A, 0x20   ; EISDIR: Is Directory!
                db   0x49, 0x73, 0x20, 0x44, 0x69, 0x72, 0x65
                db   0x63, 0x74, 0x6F, 0x72, 0x79, 0x21, 0x0a
                db   0x0d, 0x00
    _eisdir_sz  equ  $ - _eisdir
    _eacces     db   0x45, 0x41, 0x43, 0x43, 0x45, 0x53, 0x53, 0x3A   ; EACCES: Permission Denied
                db   0x20, 0x50, 0x65, 0x72, 0x6D, 0x69, 0x73
                db   0x73, 0x69, 0x6F, 0x6E, 0x20, 0x44, 0x65
                db   0x6E, 0x69, 0x65, 0x64, 0x21, 0x0a, 0x0d
                db   0x00
    _eacces_sz  equ  $ - _eacces
    _efault     db   0x45, 0x46, 0x41, 0x55, 0x4C, 0x54, 0x3A, 0x20   ; EFAULT: Bad Address
                db   0x42, 0x61, 0x64, 0x20, 0x41, 0x64, 0x64
                db   0x72, 0x65, 0x73, 0x73, 0x21, 0x0a, 0x0d
                db   0x00
    _efault_sz  equ  $ - _efault
    _einval     db   0x45, 0x49, 0x4E, 0x56, 0x41, 0x4C, 0x3A, 0x20   ; EINVAL: Invalid Argument
                db   0x49, 0x73, 0x20, 0x49, 0x6E, 0x76, 0x61
                db   0x6C, 0x69, 0x64, 0x20, 0x41, 0x72, 0x67
                db   0x75, 0x6D, 0x65, 0x6E, 0x74, 0x21, 0x0a
                db   0x0d, 0x00
    _einval_sz  equ  $ - _einval
    _enospc     db   0x45, 0x4E, 0x4F, 0x53, 0x50, 0x43, 0x3A, 0x20   ; ENOSPC: No Space Left on Device
                db   0x4E, 0x6F, 0x20, 0x53, 0x70, 0x61, 0x63
                db   0x65, 0x20, 0x4C, 0x65, 0x66, 0x74, 0x20
                db   0x6F, 0x6E, 0x20, 0x44, 0x65, 0x76, 0x69
                db   0x63, 0x65, 0x21, 0x0a, 0x0d, 0x00
    _enospc_sz  equ  $ - _enospc
    _emfile     db   0x45, 0x4D, 0x46, 0x49, 0x4C, 0x45, 0x3A, 0x20   ; EMFILE: Too Many Open Files
                db   0x54, 0x6F, 0x6F, 0x20, 0x4D, 0x61, 0x6E
                db   0x79, 0x20, 0x4F, 0x70, 0x65, 0x6E, 0x20
                db   0x46, 0x69, 0x6C, 0x65, 0x73, 0x21, 0x0a
                db   0x0d, 0x00
    _emfile_sz  equ  $ - _emfile
    _enfile     db   0x45, 0x4E, 0x46, 0x49, 0x4C, 0x45, 0x3A, 0x20   ; ENFILE: Too Many Open Files in System
                db   0x54, 0x6F, 0x6F, 0x20, 0x4D, 0x61, 0x6E
                db   0x79, 0x20, 0x4F, 0x70, 0x65, 0x6E, 0x20
                db   0x46, 0x69, 0x6C, 0x65, 0x73, 0x20, 0x69
                db   0x6E, 0x20, 0x53, 0x79, 0x73, 0x74, 0x65
                db   0x6D, 0x21, 0x0a, 0x0d, 0x00
    _enfile_sz  equ  $ - _enfile
    _erofs      db   0x45, 0x52, 0x4F, 0x46, 0x53, 0x3A, 0x20        ; EROFS: Read-Only File System
                db   0x52, 0x65, 0x61, 0x64, 0x2D, 0x4F, 0x6E
                db   0x6C, 0x79, 0x20, 0x46, 0x69, 0x6C, 0x65
                db   0x20, 0x53, 0x79, 0x73, 0x74, 0x65, 0x6D
                db   0x21, 0x0a, 0x0d, 0x00
    _erofs_sz   equ  $ - _erofs
    _enametooolong db   0x45, 0x4E, 0x41, 0x4D, 0x45, 0x54, 0x4F, 0x4F; ENAMETOOLONG: File Name Too Long
                db   0x4C, 0x4F, 0x4E, 0x47, 0x3A, 0x20, 0x46
                db   0x69, 0x6C, 0x65, 0x20, 0x4E, 0x61, 0x6D
                db   0x65, 0x20, 0x54, 0x6F, 0x6F, 0x20, 0x4C
                db   0x6F, 0x6E, 0x67, 0x21, 0x0a, 0x0d, 0x00
    _enametooolong_sz equ  $ - _enametooolong
    _enotempty  db   0x45, 0x4E, 0x4F, 0x54, 0x45, 0x4D, 0x54, 0x59   ; ENOTEMPTY: Directory Not Empty
                db   0x3A, 0x20, 0x44, 0x69, 0x72, 0x65, 0x63
                db   0x74, 0x6F, 0x72, 0x79, 0x20, 0x4E, 0x6F
                db   0x74, 0x20, 0x45, 0x6D, 0x70, 0x74, 0x79
                db   0x21, 0x0a, 0x0d, 0x00
    _enotempty_sz equ  $ - _enotempty

    _pnum_      db   '               ', 0x0 ; ascii rapresentation of d
    _pnum2_     db   '               ', 0x0 ; ascii rapresentation of d
    _pnumSZ_    equ  $ - _pnum_   
    _fd_        db   0        
    _maxfns_    equ  0x00ff
    string db "string", 0
segment .bss 
    _fn_        resb 0b00010000  ; max 16 bytes for filename
    _eOPC_      resb 0x00000000  ; memory address variable for error code reference
%macro print 2                  ; [1=buffer;2=size]
    mov  rax, sys_write         ; write syscall
    mov  rdi, stout             ; standard output code
    lea  rsi, [%1]              ; load address of string
    mov  rdx, %2                ; load size of string
    syscall 
%endmacro

%macro prompt 2                 ; [1=buffer;2=size]
    mov  rax, sys_read          ; read syscall
    mov  rdi, stin              ; for reading
    mov  rsi, %1                ; buffer
    mov  rdx, %2                ; buffer size
    syscall
%endmacro
%assign testnum 2345
segment .text

%macro int2str 1
    mov r8,  %1
    mov rsi, 10
    mov rax, r8
    lea rdi, [_pnum_]
    xor r15, r15
    _loop:
    xor rdx, rdx
    div rsi
    add rdx, 48
    mov byte [rdi], dl
    inc rdi
    inc r15
    cmp rax, 0
    jne _loop
    mov rbx, r15
    inc rbx
    xor r12, r12
    sub rdi, r15
    dec r15
    lea rsi, [rdi]
    l2:
    mov al, [rsi + r12]
    inc r12
    push rax
    dec r15
    cmp r15, -1
    jle l2done
    jmp l2
    l2done:
    lea rsi, [_pnum2_]
    xor r11, r11
    _popback:
        pop rax
        mov [rsi + r11], rax
        inc r11
        cmp r11, r12
        jne _popback    
    mov byte [rsi + r11], 0x0
    lea rax, [rsi]
%endmacro
    
_start:
    __EZprologue:
    xor r11, r11
    lea r11, [_pnum2_]
    mov byte [r11+0], 'V'
    mov byte [r11+1], 'A'
    mov byte [r11+2], 'L'
    mov byte [r11+3], 'U'
    mov byte [r11+4], 'E'
    mov byte [r11+5], ':'
    mov byte [r11+6], ' '
    mov byte [r11+7], 0
    mov r12, 8
    
    print r11, r12
    mov r8, 3394893943454
    int2str r8
    mov r10, rax
    mov r12, rbx
    print r10, r12


        jmp __EZepilogue              ; do not fall-through exception block
    __EZexcept_control:               ; exception handling control block
        cmp byte [_eOPC_], -0x000D    ; EACCES  -13
        je __eacces                   
        cmp byte [_eOPC_], -0x000B    ; EEXIST  -11
        je __eexist
        cmp byte [_eOPC_], -0x000E    ; EFAULT  -14
        je __efault
        cmp byte [_eOPC_], -0x0016    ; EINVAL  -22
        je __einval
        cmp byte [_eOPC_], -0x0002    ; ENOENT  -2
        je __enoent
        cmp byte [_eOPC_], -0x001C    ; ENOSPC  -28
        je __enospc
        cmp byte [_eOPC_], -0x0014    ; ENOTDIR -20
        je __enotdir
        cmp byte [_eOPC_], -0x0015    ; EISDIR  -21
        je __eisdir
        cmp byte [_eOPC_], -0x0018    ; EMFILE  -24
        je __emfile
        cmp byte [_eOPC_], -0x001B    ; ENFILE  -27
        je __enfile
        cmp byte [_eOPC_], -0x001E    ; EROFS   -30
        je __erofs
        cmp byte [_eOPC_], -0x001D    ; ENOEMPTY -39
        je __enotempty
        cmp byte [_eOPC_], -0x0024    ; ENAMETOOLONG -36
        jmp __enametoolong
        
        ; no match...
        jmp __enocase                 ; default case
        __eacces:
            print _eacces, _eacces_sz 
            jmp __efinal
        __eexist: 
            print _eexist, _eexist_sz  
            jmp __efinal
        __efault:
            print _efault, _efault_sz
            jmp __efinal
        __einval:
            print _einval, _einval_sz
            jmp __efinal
        __enoent:
            print _enoent, _enoent_sz
            jmp __efinal
        __enospc:
            print _enospc, _enospc_sz
            jmp __efinal
        __enotdir:
            print _enotdir, _enotdir_sz
            jmp __efinal
        __eisdir:
            print _eisdir, _eisdir_sz
            jmp __efinal
        __emfile:
            print _emfile, _emfile_sz
            jmp __efinal
        __enfile:
            print _enfile, _enfile_sz
            jmp __efinal
        __erofs:
            print _erofs, _erofs_sz
            jmp __efinal
        __enotempty:
            print _enotempty, _enotempty_sz
            jmp __efinal
        __enametoolong:
            print _enametooolong, _enametooolong_sz
            jmp __efinal
        __enocase:                     ; default case
            print _enocase, _enocase_sz    
        __efinal:
            ; do something...
__EZepilogue:                          ; release resource, clean up 
; clear or bho...
        
__EZexit:
    mov  rax, sys_exit   ; exit program
    xor  rdi, rdi        ; xor(reset) return value
    syscall
