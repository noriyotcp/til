#include <stdio.h>
#include <string.h>

int main() {
    char decimal[10]; // 10進数の文字列
    int weight; // 10進数の桁の重み
    int pos; // decimal[] の桁の位置
    int val; // decimal[] の桁の位置の値
    int sum; // 集計された値（変換後の10進数）

    printf("Enter a decimal number: ");
    fgets(decimal, sizeof(decimal), stdin);

    // fgets() で読み込んだ改行文字を削除
    decimal[strcspn(decimal, "\n")] = '\0';

    // 桁の重みと桁の数をかけて集計
    sum = 0;
    weight = 1;
    for (pos = strlen(decimal) - 1; pos >= 0; pos--) {
        val = decimal[pos] - '0'; // 文字を数値に変換
        printf("桁の重み: %d x 桁の数値%d = %d\n", weight, val, weight * val);
        sum += weight * val;
        weight *= 10; // 次の桁の重み。10をかける
    }

    printf("変換後の10進数: %d\n", sum);

    return 0;
}
