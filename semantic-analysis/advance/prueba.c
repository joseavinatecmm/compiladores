#include <stdio.h>

const int BASE = 5;

int calcular(int a, int b) {
    int suma = a + b;
    return suma;
}

double promedio(int a, int b) {
    return calcular(a, b) / 2.0;
}

int main() {
    int x = 4;
    int total = calcular(x, 5);
    double media = promedio(x, BASE);
    printf("total = %d, media = %.1f\n", total, media);
    int falta = calcular(x);
    int invisible = a;
    int incompatible = calcular(2.5, 5);
    return 0;
}
