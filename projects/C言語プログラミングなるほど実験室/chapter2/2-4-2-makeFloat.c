#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main() {
    char buff[80];
    uint32_t bits = 0;
    float num;

    // Get user input for sign
    printf("符号部 = ");
    fflush(stdout);
    fgets(buff, sizeof(buff), stdin);
    buff[strcspn(buff, "\n")] = '\0';
    int sign = atoi(buff);

    // Get user input for exponent (as binary)
    printf("指数部 = ");
    fflush(stdout);
    fgets(buff, sizeof(buff), stdin);
    buff[strcspn(buff, "\n")] = '\0';
    unsigned long exponent = strtoul(buff, NULL, 2);

    // Get user input for mantissa (as binary)
    printf("仮数部 = ");
    fflush(stdout);
    fgets(buff, sizeof(buff), stdin);
    buff[strcspn(buff, "\n")] = '\0';
    unsigned long mantissa = strtoul(buff, NULL, 2);

    // Combine the parts: sign, exponent, and mantissa
    bits |= (sign << 31);
    bits |= (exponent << 23);
    bits |= mantissa;

    // Convert the 32-bit representation to float
    memcpy(&num, &bits, sizeof(float));

    // Display the float value
    printf("float型の値 = %f\n", num);

    return 0;
}
