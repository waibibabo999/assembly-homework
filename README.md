# 汇编语言课程作业

DOSBox + MASM 5.0（16 位 DOS 汇编）环境下完成的课程作业，包含源码、说明文档和 C 版本的反汇编注释。

## 运行环境

- DOSBox 0.74
- MASM 5.00 + LINK 3.60（汇编、链接）
- DEBUG（反汇编、调试）
- Turbo C++ 3.00（仅 C 语言版本使用）

## 作业列表

| 目录 | 内容 |
| --- | --- |
| `00-hello-world` | 作业1：搭建环境 + Hello World（两种方式） |
| `01-ascii-table` | 作业2：按要求打印 ASCII 表 |
| `02-base-conversion` | 课堂练习：进制转换 |
| `03-sum` | 作业3：求和 |
| `04-mul-table` | 作业4：九九乘法表（乘法指令 + 过程调用） |

### 00-hello-world

要求：搭建环境，用常规方式运行 Hello World 实例，用直接写内存方式运行，理解程序基本结构和常用寄存器作用。

- `hello1.asm`：常规方式，用 `INT 21H` 的 `09H` 功能输出以 `'$'` 结尾的字符串
- `hello2.asm`：直接写显存方式，把字符直接写进 `B800H` 段的显存（属性 `07H` 黑底白字），不经过 DOS/BIOS
- `作业1_程序结构与寄存器.txt`：程序基本结构、两种显示方式对比、常用寄存器作用说明

运行效果：

```
D:\>hello1
Hello, World!

D:\>hello2
（屏幕第 12 行中间出现 Hello, World!）
```

说明：`hello2` 直接写显存，所以用 `>` 重定向看不到输出，必须看屏幕；可以在 DEBUG 里用 `d b800:07c2 l 1a` 看到 `48 07 65 07 …`（`48` 是 `'H'`，`07` 是属性）。

### 01-ascii-table

要求：输出 ASCII 表的小写字母部分，每行 13 个字符。

- `ascii1.asm`：用 `loop` 实现（双重循环，`push cx` / `pop cx` 保存外层计数）
- `ascii2.asm`：用条件跳转实现（`dec cx` + `jnz`，外层用字符与 `'z'` 比较）
- `ascii3.c`：C 语言实现
- `ascii3_反汇编注释.txt`：C 版本编译后 DEBUG 反汇编的逐行注释
- `ASCII3.ASM`：Turbo C 生成的汇编清单

输出：

```
abcdefghijklm
nopqrstuvwxyz
```

### 02-base-conversion

要求：输入 1~2 位 16 进制数，输出对应的 10 进制数；附加实现 10 进制向 16 进制的转换。

- `exchange.asm`

运行效果：

```
D:\>exchange
Please input a Hex number:
ff
The Dec number:
255
Please input a Dec number:
255
The Hex number:
FF
```

### 03-sum

要求：求 1+2+…+100 并把结果 5050 打印到屏幕；演示结果放在寄存器 / 数据段 / 栈；输入 1~100 的任意数求和；C 版本反汇编并加注释。

- `sum.asm`：基本要求，并演示三种存放位置
- `sum2.asm`：输入 N（1~100），输出 1+2+…+N
- `sum3.c` + `sum3_反汇编注释.txt`：C 版本及反汇编注释

运行效果：

```
D:\>sum
5050

D:\>sum2
Please input a number (1-100):
37
The sum is:
703
```

### 04-mul-table

要求：输出九九乘法表；至少实现一个过程调用（CALL / RET），过程中要用到主过程的寄存器并做保存 / 恢复；复习双重循环；C 版本反汇编并加注释。

- `mul9.asm`：汇编实现，双重循环 + `print_item` / `print_num` 两个过程，过程内 `push`/`pop` 保护 AX/BX/CX/DX
- `mul9.c`：C 语言实现
- `mul9_反汇编注释.txt`：C 版本的反汇编逐行注释（`IMUL`、`printf` 参数压栈、`putchar` 宏展开等）

输出效果（每列宽 9）：

```
The 9mul9 table:
9*1=9    9*2=18   9*3=27   9*4=36   9*5=45   9*6=54   9*7=63   9*8=72   9*9=81
8*1=8    8*2=16   8*3=24   8*4=32   8*5=40   8*6=48   8*7=56   8*8=64
...
1*1=1
```

## 如何编译运行

在 DOSBox 中把本仓库目录挂成 D 盘，然后：

```bat
D:\> masm ascii1.asm;
D:\> link ascii1.obj;
D:\> ascii1
```

C 版本（需要 Turbo C，`TCC.EXE` 在 PATH 中）：

```bat
D:\> tcc -Id:\tc\include -Ld:\tc\lib ascii3.c
D:\> ascii3
```

## 说明

- 源文件统一保存为 **UTF-8（无 BOM）**，便于在 GitHub 上正常显示；中文只出现在注释里，MASM 汇编不受影响。
- 仓库只包含自己编写的源码和文档，不包含课程提供的 MASM、Turbo C 等工具链。
- `*.obj`、`*.exe`、`*.map`、`*.log` 属于编译产物，不纳入版本管理。
