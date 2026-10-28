%option noyywrap noinput nounput

%{
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    const char *clase;
    const char *lexema;
    size_t longitud;
} Token;

Token tokenActual;
%}

ENTERO          [0-9]+
IDENTIFICADOR   [A-Za-z_][A-Za-z0-9_]*
RESERVADA       (int|float|double|char|void|if|else|for|while|return)
OPERADOR        ("=="|"!="|"<="|">="|"++"|"--"|"+="|"-="|"="|"+"|"-"|"*"|"/"|"%"|"<"|">")
DELIMITADOR     [(){};,]
COMENTARIO      "//"[^\r\n]*
ESPACIOS        [ \t]+
SALTO           (\r\n|\r|\n)
OTRO            .

%%

{RESERVADA}     { tokenActual.clase = "PALABRA_RESERVADA"; return 1; }
{IDENTIFICADOR} { tokenActual.clase = "IDENTIFICADOR";     return 1; }
{ENTERO}        { tokenActual.clase = "ENTERO";            return 1; }
{OPERADOR}      { tokenActual.clase = "OPERADOR";          return 1; }
{DELIMITADOR}   { tokenActual.clase = "DELIMITADOR";       return 1; }
{COMENTARIO}    { /* Se cuenta, pero no se imprime como token. */ }
{ESPACIOS}      { /* Se cuentan, pero no se imprimen como tokens. */ }
{OTRO}         { tokenActual.clase = "NO_RECONOCIDO";      return 1; }

%%

int main(int argc, char *argv[])
{

    if (argc != 2) {
        fprintf(stderr, "Uso: %s archivo.c\n", argv[0]);
        return EXIT_FAILURE;
    }

    yyin = fopen(argv[1], "rb");
    if (yyin == NULL) {
        perror("No se pudo abrir el archivo");
        return EXIT_FAILURE;
    }

    while (yylex() != 0) {
        tokenActual.lexema = yytext;
        tokenActual.longitud = (size_t)yyleng;

        printf("Clase: %-18s | Lexema: %-12s | Longitud: %zu\n",
               tokenActual.clase,
               tokenActual.lexema,
               tokenActual.longitud);
    }

    if (fclose(yyin) != 0) {
        perror("No se pudo cerrar el archivo");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
