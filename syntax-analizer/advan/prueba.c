#define MAX 5 

int calcular (int a, int b) {
    int r = a + b * 2;
    return r;
}

int main () {
    int x  = 4;
    int res = calcular(x, MAX);
    return 0;
}

