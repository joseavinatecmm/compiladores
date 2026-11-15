#include <stdio.h>
#include <stdlib.h>
#define FACTOR 10
#define BASE 5

 calcular(int a, int b) {
    int resultado = (a * FACTOR) + b - BASE;
    return resultado;
}

int main() {
    int x = 4;
    int total = calcular(x + 2, 8);
    return 0;
}
