#include <stdio.h>

int main() {
    int decimal;
    int binary[32];
    int pos;

    printf("Enter a decimal number: ");
    scanf("%d", &decimal);

    pos = 0;
    while (decimal > 0) {
        printf("%d / 2 = %d, remainder = %d\n", decimal, decimal / 2, decimal % 2);
        binary[pos] = decimal % 2; // あまりを下位ビットから格納
        decimal = decimal / 2;
        pos++;
    }

    printf("Binary: ");
    pos--;
    while (pos >= 0) {
        printf("%d", binary[pos]);
        pos--;
    }
    printf("\n");

    return 0;
}
