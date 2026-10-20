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
| `01-ascii-table` | 作业2：按要求打印 ASCII 表 |
| `02-base-conversion` | 课堂练习：进制转换 |
| `03-sum` | 作业3：求和 |

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
