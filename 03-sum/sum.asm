; ============================================================
; 作业3 第1小题：求和
;   基本要求：求 1+2+...+100，并把结果 "5050" 打印到屏幕
;   同时演示：结果放在 寄存器 / 数据段 / 栈 三种不同位置
;
; 说明：5050 = 13BAH，用 16 位寄存器 AX 完全放得下
;       （16 位无符号数最大 65535），所以不会溢出。
; ============================================================
stack segment stack
    db 200 dup(?)
stack ends

data segment
    result dw 0                  ; 演示"结果放在数据段"用的变量
    crlf   db 0dh, 0ah, '$'
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax

; ---------------- 求和：AX = 1 + 2 + ... + 100 ----------------
    xor ax, ax                   ; AX = 0，当累加器
    mov cx, 100                  ; 一共要加 100 次
sum_loop:
    add ax, cx                   ; AX = AX + CX
    loop sum_loop                ; CX 减 1，不为 0 就继续
                                 ; 循环结束：AX = 5050 (13BAH)

; ---------------- 1) 结果放在寄存器里 ----------------
;   此时 5050 就在 AX 里，这就是"结果放在寄存器"。
;   循环结束后 AX 里就是 13BAH（=5050）。

; ---------------- 2) 结果放在数据段里 ----------------
    mov result, ax               ; 把 AX 存进数据段的 result 变量
    mov ax, result               ; 再从 result 读回 AX（演示数据段读写）
;   在 DEBUG 里查看数据段内存，可以看到 1A 13（低字节在前，即 13BAH = 5050）。

; ---------------- 3) 结果放在栈里 ----------------
    push ax                      ; 把结果压入栈
    pop  ax                      ; 再弹回 AX（栈是后进先出）

; ---------------- 打印十进制结果 ----------------
    call print_dec               ; 打印 AX = 5050
    mov dx, offset crlf
    mov ah, 09h
    int 21h                      ; 换行

    mov ax, 4c00h
    int 21h                      ; 返回 DOS

; ============================================================
; print_dec：把 AX 里的数按十进制打印出来
;   做法：反复除以 10，余数压栈，最后倒着弹出来打印
; ============================================================
print_dec:
    mov bx, 10
    xor cx, cx                   ; CX 记录有几位
pd_div:
    xor dx, dx                   ; 除法前必须清零 DX（被除数是 DX:AX）
    div bx                       ; AX = 商, DX = 余数
    push dx                      ; 余数就是这一位的数字
    inc cx
    test ax, ax
    jnz pd_div
pd_out:
    pop dx
    add dl, '0'                  ; 数字 -> 字符
    mov ah, 02h
    int 21h
    loop pd_out
    ret

code ends
    end start
