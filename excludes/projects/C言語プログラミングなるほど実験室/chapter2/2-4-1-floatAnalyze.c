#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to convert a 32-bit integer to a binary string
char *uint32_to_binary(uint32_t num) {
    char *binary = (char *)malloc(33 * sizeof(char)); // 32 bits + null terminator
    for (int i = 31; i >= 0; i--) {
        binary[31 - i] = (num >> i) & 1 ? '1' : '0';
    }
    binary[32] = '\0';
    return binary;
}

int main() {
    char s[80];
    float num;
    uint32_t bits;

    // 文字列の入力
    printf("小数点数 = ");
    fgets(s, sizeof(s), stdin);
    s[strcspn(s, "\n")] = '\0';

    // 文字列をfloatに変換
    num = strtof(s, NULL);

    // floatのビット表現を取得
    memcpy(&bits, &num, sizeof(float));

    // 各部のビットマスク
    uint32_t sign_mask = 0x80000000;
    uint32_t exponent_mask = 0x7F800000;
    uint32_t mantissa_mask = 0x007FFFFF;

    // 各部の値を取得
    int sign = (bits & sign_mask) ? 1 : 0; // 符号部は0または1で表示
    long exponent = ((bits & exponent_mask) >> 23) - 127;
    long mantissa = bits & mantissa_mask;

    // Convert to binary string
    char *binary = uint32_to_binary(bits);

    // Print the binary representation with hyphens
    printf("%.1s-%.8s-%.23s\n", binary, binary + 1, binary + 9);

    free(binary); // Free the allocated memory

    return 0;
}
