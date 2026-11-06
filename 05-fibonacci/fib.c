/* ============================================================
   作业5 第7小题：用 C 语言实现递归斐波那契，
   再察看反汇编代码并加注释
   ============================================================ */

#include <stdio.h>

unsigned long fib(unsigned int n)
{
    if (n < 2)
        return n;

    return fib(n - 1) + fib(n - 2);
}

int main(void)
{
    unsigned int n;

    printf("n = ");
    scanf("%u", &n);

    if (n < 1 || n > 47) {
        printf("out of range\n");
        return 1;
    }

    printf("F(%u) = %lu\n", n, fib(n));
    return 0;
}
