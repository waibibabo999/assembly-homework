; ============================================================
; 作业4：乘法指令和过程调用 —— 输出九九乘法表
;   基本要求：至少实现一个过程调用（CALL / RET）
;   过程里用到主过程的寄存器资源，并做保存 / 恢复
;   双循环：外层 9 行，内层从 1 乘到当前行号
;
; 输出效果（每列宽 9）：
;   The 9mul9 table:
;   9*1=9    9*2=18   9*3=27   ...   9*9=81
;   8*1=8    8*2=16   ...
;   ...
;   1*1=1
; ============================================================
stack segment stack
    db 200 dup(?)
stack ends

data segment
    msg  db 'The 9mul9 table:', 0dh, 0ah, '$'
    crlf db 0dh, 0ah, '$'
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax

    mov dx, offset msg
    mov ah, 09h
    int 21h                         ; 打印标题

    mov di, 9                       ; DI = 行号，从 9 到 1
row_loop:
    mov si, 1                       ; SI = 列号，从 1 到行号
    mov cx, di                      ; 内层循环次数 = 行号
col_loop:
    call print_item                 ; ★ 过程调用：打印 "行*列=积"
    inc si                          ; 列号 + 1
    loop col_loop                   ; CX 减 1，不为 0 继续本行

    mov dx, offset crlf             ; 一行结束，换行
    mov ah, 09h
    int 21h

    dec di                          ; 行号 - 1
    jnz row_loop                    ; 行号不为 0 就打印下一行

    mov ax, 4c00h
    int 21h

; ============================================================
; print_item：打印 "DI * SI = 积"，并按 9 个字符的宽度补空格
;   入口：DI = 行号，SI = 列号，CX = 本行还剩几个
;   过程内部会用到 AX、BX、CX、DX，所以进来先全部压栈，
;   返回前再全部弹出恢复 —— 主过程的循环计数 CX 不会被破坏。
; ============================================================
print_item:
    push ax
    push bx
    push cx
    push dx

    mov ax, di
    call print_num                  ; 打印行号
    mov dl, '*'
    mov ah, 02h
    int 21h
    mov ax, si
    call print_num                  ; 打印列号
    mov dl, '='
    mov ah, 02h
    int 21h

    mov ax, di
    mul si                          ; ★ 乘法指令：AX = DI * SI（DX=0）
    call print_num                  ; 打印乘积

    cmp cx, 1                       ; 本行最后一个不补空格，避免超出行宽
    je  pi_done

    mov ax, di
    mul si                          ; 重新算一次积，用来判断是 1 位还是 2 位
    cmp ax, 10
    jae pi_pad3
    mov bx, 4                       ; 1 位数：补 4 个空格
    jmp pi_pad
pi_pad3:
    mov bx, 3                       ; 2 位数：补 3 个空格
pi_pad:
    mov dl, ' '
    mov ah, 02h
    int 21h
    dec bx
    jnz pi_pad

pi_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret                             ; ★ 过程返回

; ============================================================
; print_num：把 AX 里的数按十进制打印
;   内部会破坏 AX/BX/CX/DX，所以同样先保存、后恢复
; ============================================================
print_num:
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx
pn_div:
    xor dx, dx
    div bx                          ; AX = 商，DX = 余数
    push dx
    inc cx
    test ax, ax
    jnz pn_div
pn_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_out

    pop dx
    pop cx
    pop bx
    pop ax
    ret

code ends
    end start
