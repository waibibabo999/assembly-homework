; ============================================================
; 课堂练习题：进制转换
;   基本要求：输入 1~2 位 16 进制数，输出对应的 10 进制数
;   追加要求：实现 10 进制向 16 进制的转换
;
; 运行效果：
;   D:\>exchange
;   Please input a Hex number:
;   ff
;   The Dec number:
;   255
;   Please input a Dec number:
;   255
;   The Hex number:
;   FF
;
; 输入范围：0 ~ 255（因为只处理 1~2 位 16 进制数）
; ============================================================
stack segment stack
    db 200 dup(?)
stack ends

data segment
    msg1 db 'Please input a Hex number:', 0dh, 0ah, '$'
    msg2 db 'The Dec number:', 0dh, 0ah, '$'
    msg3 db 'Please input a Dec number:', 0dh, 0ah, '$'
    msg4 db 'The Hex number:', 0dh, 0ah, '$'
    crlf db 0dh, 0ah, '$'
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax                  ; 让 DS 指向数据段，后面才能用 09H 功能输出字符串

; ---------------- 基本要求：16 进制 -> 10 进制 ----------------
    mov dx, offset msg1
    mov ah, 09h
    int 21h                     ; 输出 "Please input a Hex number:"

    call read_hex               ; 读入 1~2 位 16 进制数，结果放在 SI

    mov dx, offset msg2
    mov ah, 09h
    int 21h                     ; 输出 "The Dec number:"

    mov ax, si
    call print_dec              ; 把 SI 里的数按 10 进制打印

    mov dx, offset crlf
    mov ah, 09h
    int 21h

; ---------------- 追加要求：10 进制 -> 16 进制 ----------------
    mov dx, offset msg3
    mov ah, 09h
    int 21h                     ; 输出 "Please input a Dec number:"

    call read_dec               ; 读入 10 进制数，结果放在 SI

    mov dx, offset msg4
    mov ah, 09h
    int 21h                     ; 输出 "The Hex number:"

    mov ax, si
    call print_hex              ; 把 SI 里的数按 16 进制打印

    mov dx, offset crlf
    mov ah, 09h
    int 21h

    mov ax, 4c00h
    int 21h                     ; 返回 DOS

; ============================================================
; read_hex：从键盘读入 16 进制字符，结果 -> SI
;   每读一位：SI = SI * 16 + 这一位的数值；读到回车结束
;   不是 0-9 / A-F / a-f 的字符直接忽略
; ============================================================
read_hex:
    xor si, si                  ; SI = 0，当累加器用
rh_next:
    mov ah, 08h
    int 21h                     ; 读一个字符到 AL（08H 不回显，下面自己回显）
    cmp al, 0dh                 ; 是回车吗？
    je  rh_cr
    push ax
    mov dl, al
    mov ah, 02h
    int 21h                     ; 把刚读到的字符显示出来（自己回显）
    pop ax
    call hex_digit              ; 把 AL 里的字符转成 0~15 的数值（CF=1 表示不合法）
    jc  rh_next
    mov cl, 4
    shl si, cl                  ; SI = SI * 16
    mov ah, 0
    add si, ax                  ; SI = SI * 16 + 新的一位
    jmp rh_next
rh_cr:
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h                     ; 输入结束，自己输出回车换行，保证光标到下一行
    ret

; ============================================================
; read_dec：从键盘读入 10 进制字符，结果 -> SI
;   每读一位：SI = SI * 10 + 这一位的数值
; ============================================================
read_dec:
    xor si, si
rd_next:
    mov ah, 08h
    int 21h                     ; 读一个字符（不回显）
    cmp al, 0dh
    je  rd_cr
    push ax
    mov dl, al
    mov ah, 02h
    int 21h                     ; 自己回显
    pop ax
    cmp al, '0'
    jb  rd_next                 ; 比 '0' 小，不是数字，丢掉
    cmp al, '9'
    ja  rd_next                 ; 比 '9' 大，不是数字，丢掉
    sub al, '0'                 ; AL = 0~9
    mov cl, al                  ; 把这一位的数值先存到 CL
    mov ch, 0
    mov ax, si
    mov bx, 10
    mul bx                      ; DX:AX = SI * 10（数值很小，结果就在 AX 里）
    mov si, ax                  ; SI = SI * 10
    add si, cx                  ; 再加上新的一位
    jmp rd_next
rd_cr:
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h                     ; 输入结束，自己输出回车换行
    ret

; ============================================================
; hex_digit：把 AL 里的字符转成数值
;   入口：AL = 字符      出口：AL = 0~15 的数值；CF=1 表示不是合法字符
; ============================================================
hex_digit:
    cmp al, '0'
    jb  hd_bad
    cmp al, '9'
    jbe hd_num                  ; '0' ~ '9'
    cmp al, 'A'
    jb  hd_lower
    cmp al, 'F'
    ja  hd_lower
    sub al, 'A' - 10            ; 'A' ~ 'F' -> 10~15
    clc
    ret
hd_lower:
    cmp al, 'a'
    jb  hd_bad
    cmp al, 'f'
    ja  hd_bad
    sub al, 'a' - 10            ; 'a' ~ 'f' -> 10~15
    clc
    ret
hd_num:
    sub al, '0'
    clc
    ret
hd_bad:
    stc
    ret

; ============================================================
; print_dec：把 AX 里的数按 10 进制打印出来
;   做法：反复除以 10，把每次的余数压栈，最后倒着弹出来打印
; ============================================================
print_dec:
    mov bx, 10
    xor cx, cx                  ; CX 用来数一共几位
pd_div:
    xor dx, dx
    div bx                      ; AX = 商, DX = 余数
    push dx                     ; 余数就是这一位的数字，先压栈
    inc cx
    test ax, ax                 ; 商为 0 就说明取完了
    jnz pd_div
pd_out:
    pop dx
    add dl, '0'                 ; 数字 -> 字符
    mov ah, 02h
    int 21h                     ; 打印这一位
    loop pd_out
    ret

; ============================================================
; print_hex：把 AX 里的数按 16 进制打印出来（2 位）
; ============================================================
print_hex:
    push ax
    mov cl, 4
    shr al, cl                  ; AL = 高 4 位
    call pr_nibble
    pop ax
    and al, 0fh                 ; AL = 低 4 位
    call pr_nibble
    ret

; pr_nibble：打印 AL 里的一个 16 进制数字（0~15），10~15 用大写 A~F
pr_nibble:
    cmp al, 10
    jb  pn_0to9
    add al, 'A' - 10
    jmp pn_out
pn_0to9:
    add al, '0'
pn_out:
    mov dl, al
    mov ah, 02h
    int 21h
    ret

code ends
    end start
