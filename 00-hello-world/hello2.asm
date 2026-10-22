; ============================================================
; 作业1：用"直接写显存"的方式输出 Hello, World!
;
;   彩色文本模式 80x25 下，显存从 B800H:0000 开始。
;   屏幕上每个字符占 2 个字节：
;       偶数字节 = 字符的 ASCII 码
;       奇数字节 = 显示属性（07H = 黑底白字）
;
;   想写在"第 12 行、第 33 列"（行列都从 0 开始数）：
;       偏移 = (12 * 80 + 33) * 2 = 1986 = 07C2H
;   所以 ES:DI 指向 B800H:07C2。
; ============================================================
stack segment stack
    db 128 dup(?)
stack ends

data segment
    msg db 'Hello, World!'      ; 13 个字符（这里不需要 '$'）
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax                  ; DS -> 数据段（用来取字符）

    mov ax, 0b800h
    mov es, ax                  ; ES -> 显存段

    mov si, offset msg          ; DS:SI -> 字符串
    mov di, 07c2h               ; ES:DI -> 第 12 行第 33 列
    mov cx, 13                  ; 一共 13 个字符
put_loop:
    mov al, [si]                ; 取一个字符
    mov ah, 07h                 ; 属性：黑底白字
    mov es:[di], ax             ; 直接写进显存（不经过 DOS / BIOS）
    inc si
    add di, 2                   ; 每个字符占 2 字节
    loop put_loop

    mov ax, 4c00h
    int 21h
code ends
    end start
