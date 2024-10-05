global _start                   ; entry point

segment .data
    ; === SYSCALL SYMBOLS ===
    SYS_READ        equ   0x00000000  ; 0
    SYS_WRITE       equ   0x00000001  ; 1
    SYS_OPEN        equ   0x00000002  ; 2
    SYS_CLOSE       equ   0x00000003  ; 3
    SYS_EXIT        equ   0x0000003C  ; 60
    SYS_MMAP        equ   0x00000009  ; 9
    SYS_UNMAP       equ   0x0000000B  ; 11
    SYS_GETDENTS    equ   0x0000004E  ; 78
    SYS_GETDENTS_64 equ   0x000000D9  ; 217
    ; === SYS_OPEN FLAGS ===
    __O_RDONLY   equ  0x00000000  ; read only
    __O_WRONLY   equ  0x00000001  ; write only
    __O_RDWR     equ  0x00000002  ; read and write
    __O_CREATE   equ  0x00000100  ; create if not exists
    __O_EXCL     equ  0x00000200  ; signal "failure" if file already exists
    __O_TRUNC    equ  0x00000400  ; truncate to 0
    __O_APPEND   equ  0x00000800  ; append to file
    __O_NONBLOCK equ  0x00001000  ; non blocking mode
    __O_SYNC     equ  0x00002000  ; write in sync mode
    __O_DSYNC    equ  0x00004000  ; write sync, but not m-data
    __O_RSYNC    equ  0x00008000  ; read sync mode
    __O_NOCTTY   equ  0x00010000  ; no controlling terminal
    __O_NOFOLLOW equ  0x00020000  ; no follow symlinks
    __O_CLEXEC   equ  0x00040000  ; close fd on exec
    __O_DIR      equ  0x00080000  ; fail if not directory
    ; === SYS_OPEN PROTECTION MODE ===
    __S_IRUSR    equ  0x00000100  ; read permissions for owner
    __S_IWUSR    equ  0x00000080  ; write permissions for owner
    __S_IXUSR    equ  0x00000040  ; execute permission for owner
    __S_IRGRP    equ  0x00000020  ; read permission for group
    __S_IWGRP    equ  0x00000010  ; write permission for the group
    __S_IXGRP    equ  0x00000008  ; execute permission for group
    __S_IROTH    equ  0x00000004  ; read permission for others
    __S_IWOTH    equ  0x00000002  ; write permission for others
    __S_IXOTH    equ  0x00000001  ; execute permission for others
    ; === STREAM MODE ===
    __STDIN      equ  0b00000000  ; 0(standard in), for stdin
    __STDOUT     equ  0b00000001  ; 1(standard out), for stdout
    ; === General ===
    __root_dir  db   '/home/user/code/asm/test-dir', 0 ; target directory
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

    __strdec_value_tmp   times 20 db   ' ', 0x0 ; ascii rapresentation of d
    __strdec_value_fin   times 20 db   ' ', 0x0 ; ascii rapresentation of d
    __strdec_value_len   equ  $ - __strdec_value_tmp   
    __max_decimal_len    equ  0x0A
    __fd                 db   0       
    __dir_buffer         times 1024 db 0        ; size of the dirent buffer to hold
 
    
segment .bss 
    __err_code      resb 0xff   ; memory address variable for error code reference
    __cdir_entity   resb 0x0F   ; current directory entity 
%macro print 2                  ; [1=buffer;2=size]
    mov  rax, SYS_WRITE         ; write syscall
    mov  rdi, __STDOUT          ; standard output code
    lea  rsi, [%1]              ; load address of string
    mov  rdx, %2                ; load size of string
    syscall 
%endmacro

%macro prompt 2                 ; [1=buffer;2=size]
    mov  rax, SYS_READ          ; read syscall
    mov  rdi, __STDIN              ; for reading
    mov  rsi, %1                ; buffer
    mov  rdx, %2                ; buffer size
    syscall
%endmacro
segment .text

; function for converting integer value into ascii string representation
; -------------------------------------
; arg1) the decimal value to convert
; returns result in RAX
; -------------------------------------
%macro int2str 1                    ; int to string conversion macro
    mov rax, %1                     ; move argument 1 into rax register
    mov rsi, 10                     ; set rsi to 10 for division
    lea rdi, [__strdec_value_tmp]   ; load effective address of output buffer into rdi
    xor rcx, rcx                    ; clear rcx for counting digits
_decimal_converter:                 ; loop to convert decimal
    cmp rcx, __strdec_value_len     ; check if threshold was hit
    jae _ldone                      ; jump to end if threshold reached
    xor rdx, rdx                    ; clear rdx at beginning of loop
    div rsi                         ; divide rax by 10, quotient in rax, remainder in rdx
    add rdx, '0'                    ; convert remainder to ASCII
    mov [rdi], dl                   ; store ASCII character in output buffer
    inc rdi                         ; move to next byte in output buffer
    inc rcx                         ; increment digit count
    test rax, rax                   ; check if rax is 0 (end of sequence)
    jnz _decimal_converter          ; repeat if not zero
    xor r12, r12                    ; clear r12 for reverse index tracking
_reverse_byte_order:                ; loop to reverse byte order
    dec rdi                         ; move index pointer to previous byte
    cmp r12, rcx                    ; compare r12 with digit count
    jae _ldone                           ; jump to end if r12 >= rcx
    mov al, [rdi]                        ; load byte from rdi into al
    mov [__strdec_value_fin + r12], al   ; store byte in reversed position
    inc r12                              ; increment reverse index
    jmp _reverse_byte_order              ; continue reversing
_ldone:                                        ; conversion done
    mov byte [__strdec_value_fin + r12], 0x0   ; null-terminate the string
    lea rax, [__strdec_value_fin]              ; load address of result into rax for return
%endmacro

; function for converting integer string value into decimal representation
; -------------------------------------
; arg1) string to convert
; returns result in RAX
; -------------------------------------
%macro str2int 1                  ; string to int conversion macro
    lea rsi, [%1]                 ; load effective address of input string into rsi
    xor rax, rax                  ; clear rax to accumulate the result
    xor rcx, rcx                  ; clear rcx for digit count
    mov rbx, 10                   ; set rbx to 10 for base conversion
_parse_string:                    ; loop to parse the string
    cmp rcx, __max_decimal_len    ; range check
    jae _done                     ; done if range > T
    movzx rdx, byte [rsi + rcx]   ; load the next byte (character) from the string
    test rdx, rdx                 ; check if we reached the null terminator
    jz _done                      ; if zero, we are done parsing
    sub rdx, '0'                  ; convert ASCII character to integer (0-9)
    cmp rdx, 9                    ; check if the character is a valid digit
    ja _done                      ; if not, exit the loop
    imul rax, rbx                 ; multiply current result by 10
    add rax, rdx                  ; add the new digit to the result
    inc rcx                       ; move to the next character
    jmp _parse_string             ; repeat for the next character
_done:                            ; conversion done
%endmacro
    
_start:
    
__EZprologue:
__EZfd_open:
    mov rax, SYS_OPEN             ; open file descriptor and return in rax new fd
    lea rdi, [__root_dir]         ; pointer to root dir name char byte sequence(string)
    mov rsi, __O_RDONLY           ; open for read only
    xor rdx, rdx
    syscall                       ; open
    mov byte [__err_code], al     ; store error code into __err_code
    cmp byte [__err_code], -0x01  ; check for errors
    jle __EZexcept_control        ; errors? transfer control
    mov [__fd], rax               ; store new file descriptor into __fd variable
    cmp byte [__fd], 0x03         ; is __fd id >= 3?
    jb __enotdir
    
__EZdirscan:
    mov rax, SYS_GETDENTS_64      ; sys_getdents64(64-bit mode) for directory scanning
    mov rdi, [__fd]               ; load fd id
    lea rsi, [__dir_buffer]       ; load address to store result structure
    mov rdx, 0x400                ; max number of bytes for structure
    syscall
    test rax, rax                 ; verify syscall result
    JZ __EPscan_end               ; end of scanning
    mov rbx, rax                  ; n of bytes read from fd
    xor rcx, rcx
    xor rdx, rdx
__snext:                          ; directory traversal block
    cmp rcx, rbx                  ; check if end of directory
    jae __EPscan_end
    movzx rdx, byte [__dir_buffer + rcx + 0x10]
    lea rsi, [__dir_buffer + rcx + 0x13]
    add rcx, rdx
    jmp __snext

__EPscan_end:                     ; close directory descriptor
    mov rax, SYS_CLOSE
    mov rdi, [__fd]
    syscall
    jmp __EZepilogue
    __EZexcept_control:                   ; exception handling control block
        cmp byte [__err_code], -0x000D    ; EACCES  -13
        je __eacces                   
        cmp byte [__err_code], -0x000B    ; EEXIST  -11
        je __eexist
        cmp byte [__err_code], -0x000E    ; EFAULT  -14
        je __efault
        cmp byte [__err_code], -0x0016    ; EINVAL  -22
        je __einval
        cmp byte [__err_code], -0x0002    ; ENOENT  -2
        je __enoent
        cmp byte [__err_code], -0x001C    ; ENOSPC  -28
        je __enospc
        cmp byte [__err_code], -0x0014    ; ENOTDIR -20
        je __enotdir
        cmp byte [__err_code], -0x0015    ; EISDIR  -21
        je __eisdir
        cmp byte [__err_code], -0x0018    ; EMFILE  -24
        je __emfile
        cmp byte [__err_code], -0x001B    ; ENFILE  -27
        je __enfile
        cmp byte [__err_code], -0x001E    ; EROFS   -30
        je __erofs
        cmp byte [__err_code], -0x001D    ; ENOEMPTY -39
        je __enotempty
        cmp byte [__err_code], -0x0024    ; ENAMETOOLONG -36
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
    mov  rax, SYS_EXIT   ; exit program
    xor  rdi, rdi        ; xor(reset) return value
    syscall


