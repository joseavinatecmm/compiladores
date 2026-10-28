%option noyywrap

%{
#include <stdio.h>
%}

ENTERO    [0-9]+

%%

{ENTERO}    {
                printf("Clase: INTEGER | Lexema: %s | Longitud: %zu\n",
                       yytext, (size_t)yyleng);
            }

[ \t\r\n]+  { /* Omitir espacios, tabulaciones y saltos de linea */ }

.           {
                printf("Clase: DESCONOCIDA | Lexema: %s | Longitud: %zu\n",
                       yytext, (size_t)yyleng);
 
            }

%%

int main(void)
{
    yylex();
    return 0;
}
