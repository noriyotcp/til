#include <stdio.h>

int main() {
    signed char data1; // signed char
    unsigned char data2; // unsigned char

    // initialize
    data1 = 0;
    data2 = 0;

    // [q] が入力されたら繰り返しを終了する
    do {
        // print data1 and data2
        printf("符号あり = %d\t符号なし = %d", data1, data2);

        data1++;
        data2++;

    } while (getchar() != 'q');

    return 0;
}
