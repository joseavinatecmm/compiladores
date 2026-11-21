#include <stdio.h>

const int BASE = 2;

int residuo(int x) {
    int resto = x % BASE;
    return resto;
}

double ajustar(int x, double y) {
    double suma = x + y;
    return suma / BASE;
}

int main() {
    int x = 7;
    double y = 2.5;
    int r = residuo(x) + 1;
    double total = ajustar(x, y) * 2;
    printf("r = %d, total = %.2f\n", r, total);
    return 0;
}
