; ============================================================
; 作业3 第2小题：用户输入 1~100 内的任意一个数 N，
;                输出 1+2+...+N 的十进制结果
;
;   输入用 INT 21H 的 08H 功能（读一个字符，不回显），
;   程序自己把字符显示出来，这样回车后的换行由程序控制。
;
;   例：输入 37  ->  输出 703
;       输入 100 ->  输出 5050
; ============================================================
stack segment stack
    db 200 dup(?)
stack ends

data segment
    msg1   db 'Please input a number (1-100):', 0dh, 0ah, '$'
    msg2   db 'The sum is:', 0dh, 0ah, '$'
    msgErr db 'Input error! Please input 1-100.', 0dh, 0ah, '$'
    crlf   db 0dh, 0ah, '$'
    result dw 0                  ; 存放求和结果（后面要打印提示语，会破坏 AX）
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax

    mov dx, offset msg1
    mov ah, 09h
    int 21h                      ; 输出提示

    call read_dec                ; 读入十进制数 -> SI

    cmp si, 1                    ; 检查下界
    jb  input_error
    cmp si, 100                  ; 检查上界
    ja  input_error

; ---------------- 求和：AX = 1 + 2 + ... + SI ----------------
    xor ax, ax                   ; AX = 0
    mov cx, si                   ; 循环次数 = N
add_loop:
    add ax, cx                   ; AX = AX + CX
    loop add_loop
;   注意：如果 N = 0，loop 会把 CX 从 0 减到 FFFFH 循环 65536 次，
;   所以上面必须先检查 SI >= 1，不能让 N 为 0。
    mov result, ax               ; ★ 先把结果存进数据段：
;   因为下一句 mov ah,09h 会改写 AX 的高字节 AH，
;   5050 (13BAH) 会变成 09BAH = 2490，所以必须先保存。

    mov dx, offset msg2
    mov ah, 09h
    int 21h                      ; 输出 "The sum is:"

    mov ax, result               ; 把结果取回来
    call print_dec               ; 打印 AX
    mov dx, offset crlf
    mov ah, 09h
    int 21h
    jmp done

input_error:
    mov dx, offset msgErr
    mov ah, 09h
    int 21h

done:
    mov ax, 4c00h
    int 21h                      ; 返回 DOS

; ============================================================
; read_dec：从键盘读入十进制字符，结果 -> SI
;   每读一位：SI = SI * 10 + 这一位的数值；回车结束
; ============================================================
read_dec:
    xor si, si
rd_next:
    mov ah, 08h
    int 21h                      ; 读一个字符（不回显）
    cmp al, 0dh                  ; 回车？
    je  rd_cr
    push ax
    mov dl, al
    mov ah, 02h
    int 21h                      ; 自己回显
    pop ax
    cmp al, '0'
    jb  rd_next                  ; 不是数字，丢掉
    cmp al, '9'
    ja  rd_next
    sub al, '0'                  ; AL = 0~9
    mov cl, al                   ; 暂存这一位
    mov ch, 0
    mov ax, si
    mov bx, 10
    mul bx                       ; DX:AX = SI * 10
    mov si, ax                   ; SI = SI * 10
    add si, cx                   ; 加上新的一位
    jmp rd_next
rd_cr:
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h                      ; 回车换行
    ret

; ============================================================
; print_dec：把 AX 里的数按十进制打印出来
; ============================================================
print_dec:
    mov bx, 10
    xor cx, cx
pd_div:
    xor dx, dx
    div bx                       ; AX = 商, DX = 余数
    push dx
    inc cx
    test ax, ax
    jnz pd_div
pd_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pd_out
    ret

code ends
    end start
