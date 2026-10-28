%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
%}

ENTERO          [0-9]+
IDENTIFICADOR   [A-Za-z_][A-Za-z0-9_]*

%%

"int"|"float"|"double"|"char"|"void"|"const"|"if"|"else"|"for"|"while"|"return" {
    printf("Clase: PALABRA_RESERVADA | Lexema: %s\n", yytext);
}

{IDENTIFICADOR} {
    printf("Clase: IDENTIFICADOR | Lexema: %s | Longitud: %zu\n",
           yytext, (size_t)yyleng);
}

{ENTERO} {
    printf("Clase: ENTERO | Lexema: %s | Longitud: %zu\n",
           yytext, (size_t)yyleng);
}

[ \t\r\n]+ {
    /* Omitir espacios, tabulaciones y saltos de linea. */
}

. {
    printf("Caracter no reconocido: %s\n", yytext);
}

%%

int main(void)
{
    yylex(); 
    return EXIT_SUCCESS;
}
