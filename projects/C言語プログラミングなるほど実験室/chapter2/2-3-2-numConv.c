// 数字列を数値に変換するプログラム
#include <stdio.h>
#include <string.h>

int main() {
    char s[80]; // 文字列を格納する配列（変換前）
    int sum; // 数値に変換した合計値
    int pos; // 文字列の位置

    // 文字列の入力
    printf("数字列:");
    fgets(s, sizeof(s), stdin);
    s[strcspn(s, "\n")] = '\0';

    // 数字列を数値に変換する
    sum = 0;
    pos = 0;
    while (s[pos] != '\0') {
        // 直前に集計したsumに10をかけて、桁の重みをかける
        sum = sum * 10 + (s[pos] - 0x30);
        pos++;
    }

    /*
      123 を入力する。10をかけて繰り上げしている
      [0] sum = 0 * 10 + (1 - 0x30) = 1
      [1] sum = 1 * 10 + (2 - 0x30) = 12
      [2] sum = 12 * 10 + (3 - 0x30) = 123
    */
    // 変換後の文字列を表示
    printf("変換後の数値：%d\n", sum);

    return 0;
}
