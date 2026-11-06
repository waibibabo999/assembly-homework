; ============================================================
; 作业5：递归调用 —— 斐波那契数列
;   F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2)
;
;   输入 n（1~47），递归求 F(n)，输出 32 位十进制结果。
;
;   为什么最大是 47：
;     32 位无符号数最大 4294967295，
;     F(47)=2971215073 放得下，F(48)=4807526976 就溢出了。
;
;   栈空间：
;     每次递归压入 返回地址2 + BP2 + n2 + F(n-1)4 = 10 字节，
;     深度最多 100 层 → 约 1000 字节，这里开 2048 字节，安全。
; ============================================================
stack segment stack
    db 2048 dup(?)
stack ends

data segment
    msg1   db 'Please input n (1-47):', 0dh, 0ah, '$'
    msg2   db 'F(n) = ', '$'
    msgErr db 'Out of range! n must be 1-47.', 0dh, 0ah, '$'
    crlf   db 0dh, 0ah, '$'
    resLo  dw 0                  ; 保存结果的低 16 位
    resHi  dw 0                  ; 保存结果的高 16 位
data ends

code segment
    assume cs:code, ds:data, ss:stack
start:
    mov ax, data
    mov ds, ax

    mov dx, offset msg1
    mov ah, 09h
    int 21h                      ; 打印提示

    call read_dec                ; 读入 n → SI
    cmp si, 1                    ; 范围检查
    jb  out_range
    cmp si, 47
    ja  out_range

    mov ax, si
    call fib                     ; ★ 递归调用，返回 DX:AX = F(n)

    mov resLo, ax                ; 先保存结果：后面打印提示会改 AX
    mov resHi, dx

    mov dx, offset msg2
    mov ah, 09h
    int 21h                      ; 打印 "F(n) = "

    mov ax, resLo
    mov dx, resHi
    call print_u32               ; 打印 32 位十进制数

    mov dx, offset crlf
    mov ah, 09h
    int 21h                      ; 换行
    jmp done

out_range:
    mov dx, offset msgErr
    mov ah, 09h
    int 21h

done:
    mov ax, 4c00h
    int 21h                      ; 返回 DOS

; ============================================================
; fib：递归求斐波那契
;   入口：AX = n
;   出口：DX:AX = F(n)（32 位）
;   栈帧（进入 fib_rec 后）：
;       [BP+0] 旧 BP     [BP-2] n
;       [BP-4] F(n-1)低  [BP-6] F(n-1)高
; ============================================================
fib:
    cmp ax, 1
    ja  fib_rec                  ; n > 1 → 递归
    xor dx, dx                   ; n=0 → 0；n=1 → 1（AX 已经是 n）
    ret

fib_rec:
    push bp                      ; 保存调用者的 BP
    mov bp, sp                   ; BP 指向本层栈帧
    push ax                      ; [BP-2] = n

    dec ax                       ; AX = n-1
    call fib                     ; DX:AX = F(n-1)
    push ax                      ; [BP-4] = F(n-1) 的低 16 位
    push dx                      ; [BP-6] = F(n-1) 的高 16 位

    mov ax, [bp-2]               ; 取回 n
    sub ax, 2                    ; AX = n-2
    call fib                     ; DX:AX = F(n-2)

    add ax, [bp-4]               ; 低 16 位相加
    adc dx, [bp-6]               ; 高 16 位相加 + 进位

    mov sp, bp                   ; 一次回收本层所有临时数据
    pop bp                       ; 恢复调用者的 BP
    ret                          ; 返回到上一层

; ============================================================
; read_dec：从键盘读入十进制数 → SI（08H 读字符，自己回显）
; ============================================================
read_dec:
    xor si, si
rd_next:
    mov ah, 08h
    int 21h
    cmp al, 0dh                  ; 回车结束
    je  rd_cr
    push ax
    mov dl, al
    mov ah, 02h
    int 21h                      ; 自己回显
    pop ax
    cmp al, '0'
    jb  rd_next
    cmp al, '9'
    ja  rd_next
    sub al, '0'                  ; 字符 → 数字
    mov cl, al
    mov ch, 0
    mov ax, si
    mov bx, 10
    mul bx                       ; SI × 10
    mov si, ax
    add si, cx                   ; + 新的一位
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
; print_u32：把 DX:AX 按无符号十进制打印
; ============================================================
print_u32:
    push bp
    xor bp, bp                   ; BP = 位数
pu_div:
    call div10_32                ; DX:AX = 商，CX = 余数
    push cx
    inc bp
    mov bx, ax
    or  bx, dx                   ; 商为 0？
    jnz pu_div
pu_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    dec bp
    jnz pu_out
    pop bp
    ret

; ============================================================
; div10_32：DX:AX ÷ 10
;   出口：DX:AX = 商，CX = 余数（BX 保持不变）
; ============================================================
div10_32:
    push bx
    push ax
    mov ax, dx                   ; 先除高 16 位
    xor dx, dx
    mov cx, 10
    div cx                       ; AX = 高/10，DX = 高%10
    mov bx, ax
    pop ax                       ; 取回低 16 位
    div cx                       ; DX:AX ÷ 10 → AX = 商低，DX = 余数
    mov cx, dx                   ; CX = 余数
    mov dx, bx                   ; DX = 商高
    pop bx
    ret

code ends
    end start
