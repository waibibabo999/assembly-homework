; ============================================================
; 作业2  第2小题：用条件跳转指令（不使用 loop）打印 ASCII 表小写字母
;   要求：输出 a~z，每行 13 个字符，共 2 行
;   实现：内层用 dec cx + jnz 手动计数；外层用字符本身和 'z' 比较
; ============================================================
stack segment stack
    db 128 dup(?)
stack ends

code segment
    assume cs:code, ss:stack
start:
    mov bl, 'a'          ; 当前要打印的字符放在 BL（int 21h 会破坏 AL，不能用 AL）
row:
    mov cx, 13           ; 内层：一行 13 个字符
col:
    mov dl, bl           ; 把当前字符送给 DL
    mov ah, 02h          ; DOS 02H 功能：打印 DL 里的字符
    int 21h
    inc bl               ; 指向下一个字母
    dec cx               ; 计数器减 1（dec 会自动设置"是否为零"标志）
    jnz col              ; 不为 0 就跳回 col —— 这里代替了 loop 指令

    mov dl, 0dh          ; 打印回车（光标回到行首）
    mov ah, 02h
    int 21h
    mov dl, 0ah          ; 打印换行（光标下移一行）
    mov ah, 02h
    int 21h

    cmp bl, 'z'          ; 当前字符还没超过 'z' 吗？
    jbe row              ; 没超过就跳回 row 打印下一行

    mov ax, 4c00h        ; 返回 DOS
    int 21h
code ends
    end start
