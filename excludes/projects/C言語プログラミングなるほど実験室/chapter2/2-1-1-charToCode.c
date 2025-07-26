// gcc -o charToCode charToCode.c -liconv -Wall -Wextra
// This program converts UTF-8 input to Shift-JIS encoding.
#include <stdio.h>
#include <iconv.h>
#include <string.h>

int main() {
    char input[8];
    char output[8];
    iconv_t cd;
    size_t inlen, outlen;
    char *inp, *outp;

    // UTF-8入力を受け取る
    printf("Please input a character: ");
    fgets(input, sizeof(input), stdin);
    input[strcspn(input, "\n")] = 0;  // 改行を削除

    // UTF-8からShift-JISへの変換器を作成
    cd = iconv_open("SHIFT-JIS", "UTF-8");
    if (cd == (iconv_t)-1) {
        perror("iconv_open");
        return 1;
    }

    // 変換の準備
    inlen = strlen(input);
    outlen = sizeof(output);
    inp = input;
    outp = output;

    // 文字コード変換を実行
    if (iconv(cd, &inp, &inlen, &outp, &outlen) == (size_t)-1) {
        perror("iconv");
        return 1;
    }

    // Shift-JISコードを表示
    unsigned char sjis = (unsigned char)output[0];
    printf("Character: %s, SJIS code: %02X\n", input, sjis);

    iconv_close(cd);
    return 0;
}
