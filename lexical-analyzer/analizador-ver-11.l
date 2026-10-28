%option noyywrap

%{
#include <stdio.h>

typedef struct {
    const char *clase;
    const char *lexema;
    size_t longitud;
} Token;

Token tokenActual;
%}

ENTERO          [0-9]+
IDENTIFICADOR   [A-Za-z_][A-Za-z0-9_]*
RESERVADA       (int|float|double|char|if|else|for|return)
ESPACIOS        [ \t\r\n]+
OTRO            .

%%

{RESERVADA} {
    tokenActual.clase = "PALABRA_RESERVADA";
    return 1;
}

{IDENTIFICADOR} {
    tokenActual.clase = "IDENTIFICADOR";
    return 1;
}

{ENTERO} {
    tokenActual.clase = "ENTERO";
    return 1;
}

{ESPACIOS} {
    /* Omitir espacios y saltos de linea. */
}

{OTRO} {
    tokenActual.clase = "NO_RECONOCIDO";
    return 1;
}

%%

int main(void)
{
    while (yylex() != 0) {
        tokenActual.lexema = yytext;
        tokenActual.longitud = (size_t)yyleng;

        printf("Clase: %s | Lexema: %s | Longitud: %zu\n",
               tokenActual.clase,
               tokenActual.lexema,
               tokenActual.longitud);
    }

    return 0;
}
