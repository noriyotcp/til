#include <stdio.h>
#include <iconv.h>
#include <string.h>
#include <locale.h>

void printShiftJISChar(unsigned char code) {
    // 1バイトのShift-JIS文字をUTF-8に変換して表示
    char input[2] = {code, '\0'};
    char output[8];
    char *inp = input, *outp = output;
    size_t inlen = 1, outlen = sizeof(output);

    iconv_t cd = iconv_open("UTF-8", "SHIFT-JIS");
    if (cd == (iconv_t)-1) {
        printf("   ");
        return;
    }

    if (iconv(cd, &inp, &inlen, &outp, &outlen) == (size_t)-1) {
        printf("   ");
    } else {
        *outp = '\0';
        printf("%s  ", output);
    }

    iconv_close(cd);
}

int main() {
    unsigned char code;

    // ロケールを設定
    setlocale(LC_ALL, "");

    // 出力バッファリングを無効化
    setbuf(stdout, NULL);

    // 文字コードの一覧表を表示する
    printf("+0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F\n");
    for (code = 0x00; code != 0xFF; code++) {
        // 16文字ごとに改行する。先頭の文字コードを表示する
        if (code % 16 == 0) {
            printf("\n%02X ", code);
        }

        // 表示可能な文字だけ表示する（ASCII文字と半角カタカナ）
        if ((code >= 0x20 && code <= 0x7E) || (code >= 0xA1 && code <= 0xDF)) {
            printShiftJISChar(code);
        } else {
            printf("   ");  // 表示できない文字は空白で埋める
        }
    }
    printf("\n");
    return 0;
}
