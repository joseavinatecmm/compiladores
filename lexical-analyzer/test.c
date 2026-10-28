int main(void)
{
    int total = 0;
    int limite = 5;

    // Sumar los enteros desde cero hasta limite - 1.
    for (int i = 0; i < limite; i++) {
        total += i;
    }

    if (total >= 10) {
        total = total - 1;
    }

    return total;
}
