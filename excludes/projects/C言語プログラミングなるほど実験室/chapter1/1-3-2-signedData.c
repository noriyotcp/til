#include <stdio.h>

// data を bitNum ビットの2進数で表示する
void showBinary(unsigned long data, int bitNum) {
    int binary[32]; // 変換後の2進数を格納する配列
    int pos; // binary[] の格納位置

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
    signed char data1; // signed char

    // initialize
    data1 = 0;

    // [q] が入力されたら繰り返しを終了する
    do {
        // print data1 and data2
        printf("符号あり = %d\t", data1);
        showBinary(data1, 8);

        data1++;
    } while (getchar() != 'q');

    return 0;
}
