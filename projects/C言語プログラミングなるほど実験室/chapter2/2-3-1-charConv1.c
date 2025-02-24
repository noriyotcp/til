// 文字列の内容を大文字および小文字に変換するプログラム
#include <stdio.h>
#include <string.h>

int main() {
    char s[80]; // 文字列を格納する配列（変換前）
    char upper[80]; // 大文字に変換した文字列
    char lower[80]; // 小文字に変換した文字列
    int pos; // 文字列の位置
    int diff = 'a' - 'A';

    // 文字列の入力
    printf("文字列を入力してください：");
    fgets(s, sizeof(s), stdin);
    s[strcspn(s, "\n")] = '\0';

    // 文字列を先頭から末尾までチェックする
    pos = 0;
    while (s[pos] != '\0') {
        if (s[pos] >= 'A' && s[pos] <= 'Z') {
            // 大文字を小文字に変換する
            upper[pos] = s[pos];
            lower[pos] = s[pos] + diff;
        } else if (s[pos] >= 'a' && s[pos] <= 'z') {
            // 小文字を大文字に変換する
            upper[pos] = s[pos] - diff;
            lower[pos] = s[pos];
        } else {
            // 変換しない
            upper[pos] = s[pos];
            lower[pos] = s[pos];
        }
        pos++;
    }
    upper[pos] = '\0';
    lower[pos] = '\0';

    // 変換後の文字列を表示
    printf("大文字に変換：%s\n", upper);
    printf("小文字に変換：%s\n", lower);

    return 0;
}
