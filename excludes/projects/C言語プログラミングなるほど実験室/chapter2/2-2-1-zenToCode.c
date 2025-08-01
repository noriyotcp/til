#include <iconv.h>
#include <locale.h>
#include <stdio.h>
#include <string.h>

int main() {
    unsigned char utf8_buf[16];
    unsigned char sjis_buf[8];
    unsigned short code;

    // ロケールを設定
    setlocale(LC_ALL, "ja_JP.UTF-8");

    // キーボードから文字を入力する
    printf("Enter a character: ");
    if (fgets((char *)utf8_buf, sizeof(utf8_buf), stdin) == NULL) {
        printf("Error: Failed to read input\n");
        return 1;
    }
    utf8_buf[strcspn((char *)utf8_buf, "\n")] = 0;

    // UTF-8からShift-JISへの変換設定
    iconv_t cd = iconv_open("CP932", "UTF-8");
    if (cd == (iconv_t)-1) {
        printf("Error: iconv_open failed\n");
        return 1;
    }

    // 変換用の変数
    char *inbuf = (char *)utf8_buf;
    char *outbuf = (char *)sjis_buf;
    size_t inbytes = strlen((char *)utf8_buf);
    size_t outbytes = sizeof(sjis_buf);
    memset(sjis_buf, 0, sizeof(sjis_buf));

    // UTF-8からShift-JISへ変換
    if (iconv(cd, &inbuf, &inbytes, &outbuf, &outbytes) == (size_t)-1) {
        perror("iconv");
        iconv_close(cd);
        return 1;
    }

    // Shift-JISコードを2バイト分取得
    code = ((unsigned short)sjis_buf[0] << 8) | (unsigned short)sjis_buf[1];

    // 結果を表示
    printf("Character: %s\n", utf8_buf);
    printf("Code: %04X\n", code);

    iconv_close(cd);
    return 0;
}
