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
    int data;
    char a; // 変換前のデータ
    char b; // 変換後のデータ

    printf("データ =");
    scanf("%d", &data);
    a = (char)data;

    // 反転しただけのデータを表示
    b = ~a;
    printf("\n反転だけした値と足す\n");
    showBinary(a, 8);
    printf(" + ");
    showBinary(b, 8);
    printf(" = ");
    showBinary(a + b, 8);
    printf("\n");

    // 反転して1を加算
    printf("\n反転して1を加えた値と足す\n");
    b = ~a + 1;
    showBinary(a, 8);
    printf(" + ");
    showBinary(b, 8);
    printf(" = ");
    showBinary(a + b, 8);
    printf("\n");

    return 0;
}
