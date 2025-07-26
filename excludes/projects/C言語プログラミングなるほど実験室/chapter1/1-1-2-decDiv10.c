#include <stdio.h>

int main() {
    int decimal;

    printf("Enter a decimal number: ");
    scanf("%d", &decimal);

    while (decimal > 0) {
        printf("%d / 10 = %d, remainder = %d\n", decimal, decimal / 10, decimal % 10);
        decimal = decimal / 10;
    }

    return 0;
}
