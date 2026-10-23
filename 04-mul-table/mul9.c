/* ============================================================
   作业4 第3小题：用 C 语言实现九九乘法表，
   再察看反汇编代码并加注释
   ============================================================ */

#include <stdio.h>

int main(void)
{
    int i, j;

    printf("The 9mul9 table:\n");

    for (i = 9; i >= 1; i--) {          /* 外层：行号 9 -> 1 */
        for (j = 1; j <= i; j++) {      /* 内层：列号 1 -> i */
            printf("%d*%d=%d", i, j, i * j);
            if (j != i) {               /* 最后一列不补空格 */
                putchar(' ');
                putchar(' ');
                putchar(' ');
                if (i * j < 10)
                    putchar(' ');
            }
        }
        putchar('\n');
    }

    return 0;
}
