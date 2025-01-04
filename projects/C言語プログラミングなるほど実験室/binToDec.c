#include <stdio.h>
#include <string.h>

int main() {
    char binary[32];
    int weight; // 2進数の桁の重み
    int pos; // binary[] の桁の位置
    int val; // binary[] の桁の位置の値
    int sum; // 集計された値（変換後の10進数）

    printf("Enter a binary number: ");
    fgets(binary, sizeof(binary), stdin);

    // fgets() で読み込んだ改行文字を削除
    binary[strcspn(binary, "\n")] = '\0';

    // 2進数を10進数に変換
    sum = 0;
    weight = 1;
    for (pos = strlen(binary) - 1; pos >= 0; pos--) {
        val = binary[pos] - '0'; // 文字を数値に変換
        printf("桁の重み: %d x 桁の数値%d = %d\n", weight, val, weight * val);
        sum += weight * val;
        weight *= 2; // 次の桁の重み。2をかける
    }

    printf("変換後の10進数: %d\n", sum);

    return 0;
}
