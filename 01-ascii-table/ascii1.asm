stack segment stack
    db 128 dup(?)
stack ends

code segment
    assume cs:code, ss:stack
start:
    mov bl, 'a'          ; ← 改这里：当前字符放 BL，不放 AL
    mov cx, 2            ; 外层循环：2 行
row:
    push cx              ; 保存外层的行数
    mov cx, 13           ; 内层循环：一行 13 个字符
col:
    mov dl, bl           ; ← 改这里：从 BL 取字符给 DL 去打印
    mov ah, 02h
    int 21h
    inc bl               ; ← 改这里：BL 里才是真正的字母
    loop col
    pop cx               ; 恢复外层的行数

    mov dl, 0dh          ; 打印回车
    mov ah, 02h
    int 21h
    mov dl, 0ah          ; 打印换行
    mov ah, 02h
    int 21h

    loop row             ; 外层 CX 减 1，不为 0 就打印下一行

    mov ax, 4c00h
    int 21h
code ends
    end start