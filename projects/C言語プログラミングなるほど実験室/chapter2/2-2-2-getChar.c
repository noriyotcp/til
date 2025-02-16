#include <stdio.h>
#include <string.h>
#include <iconv.h>

// 半角文字と全角文字が混在した文字列から、1文字ずつ取り出す

int convert_to_sjis(char *input, char *output, size_t outsize) {
    iconv_t cd;
    char *inp = input;
    char *outp = output;
    size_t inlen = strlen(input);
    size_t outlen = outsize;

    cd = iconv_open("SHIFT-JIS", "UTF-8");
    if (cd == (iconv_t)-1) {
        perror("iconv_open");
        return -1;
    }

    if (iconv(cd, &inp, &inlen, &outp, &outlen) == (size_t)-1) {
        perror("iconv");
        iconv_close(cd);
        return -1;
    }

    *outp = '\0';
    iconv_close(cd);
    return 0;
}

void print_utf8_char(const char *sjis_char, int len) {
    char utf8[8];
    char *inp = (char *)sjis_char;
    char *outp = utf8;
    size_t inlen = len;
    size_t outlen = sizeof(utf8);

    iconv_t cd = iconv_open("UTF-8", "SHIFT-JIS");
    if (cd == (iconv_t)-1) {
        printf("[?]");
        return;
    }

    if (iconv(cd, &inp, &inlen, &outp, &outlen) == (size_t)-1) {
        printf("[?]");
    } else {
        *outp = '\0';
        printf("[%s]", utf8);
    }

    iconv_close(cd);
}

int main() {
    char s[80], sjis[80];
    int pos;
    char zen[3]; // 全角文字

    // 文字列を入力
    printf("Enter a string: ");
    fgets(s, sizeof(s), stdin);
    s[strcspn(s, "\n")] = '\0'; // Remove the newline character if present

    // UTF-8からShift-JISに変換
    if (convert_to_sjis(s, sjis, sizeof(sjis)) < 0) {
        return 1;
    }

    // 文字列から1文字ずつ取り出す
    pos = 0;
    zen[2] = '\0'; // 2バイト目にNULL文字を入れておく

    while (sjis[pos] != '\0') {
        if (((unsigned char)sjis[pos] >= 0X20 && (unsigned char)sjis[pos] <= 0X7E) ||
            ((unsigned char)sjis[pos] >= 0XA1 && (unsigned char)sjis[pos] <= 0XDF)) {
            // 半角文字の場合
            char temp[2] = {sjis[pos], '\0'};
            print_utf8_char(temp, 1);
            pos++;
        } else if (((unsigned char)sjis[pos] >= 0X81 && (unsigned char)sjis[pos] <= 0X9F) ||
                   ((unsigned char)sjis[pos] >= 0XE0 && (unsigned char)sjis[pos] <= 0XFC)) {
            // 全角文字の場合
            char temp[3] = {sjis[pos], sjis[pos + 1], '\0'};
            print_utf8_char(temp, 2);
            pos += 2;
        } else {
            pos++;
        }
    }
    printf("\n");

    return 0;
}
