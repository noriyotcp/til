#include <stdio.h>

int main() {
    unsigned char code;

    // 文字コードの一覧表を表示する
    printf("+0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F\n");
    for (code = 0x00; code != 0xFF; code++) {
        // 16文字ごとに改行する。先頭の文字コードを表示する
        if (code % 16 == 0) {
            printf("\n%02X ", code);
        }

        // 表示可能な文字だけ表示する
        if (code >= 0x20 && code <= 0x7E || code >= 0xA1 && code <= 0xDF) {
            printf("%c ", code);
        }
    }
    printf("\n");
    return 0;
}
