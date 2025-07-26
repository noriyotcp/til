#include <stdio.h>

// data を bitNum ビットの2進数で表示する
void showBinary(unsigned long data, int bitNum) {
    int binary[32]; // 変換後の2進数を格納する配列
    int pos;        // binary[] の格納位置

    // １０進数を２進数に変換
    for (pos = 0; pos < bitNum; pos++) {
        binary[pos] = data % 2;
        data /= 2;
    }

    // 変換後の２進数を画面に表示
    for (pos = bitNum - 1; pos >= 0; pos--) {
        printf("%d", binary[pos]);
    }
}

int main() {
    char c; // signed 8-bit
    short s; // signed 16-bit
    long l; // signed 32-bit

    c = 123;

    s = c;
    l = c;
    printf("プラスの値の代入\n");
    printf("char = %d(", c);
    showBinary(c, 8);
    printf(")\n");
    printf("short = %d(", s);
    showBinary(s, 16);
    printf(")\n");
    printf("long = %ld(", l);
    showBinary(l, 21);
    printf(")\n");

    c = -123;

    s = c;
    l = c;
    printf("マイナスの値の代入\n");
    printf("char = %d(", c);
    showBinary(c, 8);
    printf(")\n");
    printf("short = %d(", s);
    showBinary(s, 16);
    printf(")\n");
    printf("long = %ld(", l);
    showBinary(l, 21);
    printf(")\n");

    return 0;
}
