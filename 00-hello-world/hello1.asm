; ============================================================
; 作业1：用"常规方式"输出 Hello, World!
;   方式：调用 DOS 中断 INT 21H 的 09H 功能，把 DS:DX 指向的、
;         以 '$' 结尾的字符串显示到屏幕上。
; ============================================================
stack segment stack
    db 128 dup(?)
stack ends

data segment
    msg db 'Hello, World!', 0dh, 0ah, '$'
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax                  ; 让 DS 指向数据段

    mov dx, offset msg          ; DS:DX -> 字符串首地址
    mov ah, 09h                 ; DOS 09H 功能：显示字符串
    int 21h

    mov ax, 4c00h               ; 返回 DOS
    int 21h
code ends
    end start
