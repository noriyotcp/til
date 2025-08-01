#include <stdio.h>

int main() {
    long l; // signed 32-bit
    short s; // signed 16-bit
    char c; // signed 8-bit

    l = 0x12345678;

    // より小さなデータ型の変数に代入
    s = l;
    c = l;

    printf("long = %lx\n", l);
    printf("short = %x\n", s);
    printf("char = %x\n", c);

    return 0;
}
