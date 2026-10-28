%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
%}

PALABRA_RESERVADA    (int|float|double|char|void|const|if)
IDENTIFICADOR       [A-Za-z_][A-Za-z0-9_]*
ENTERO              [0-9]+
DECIMAL             {ENTERO}"."{ENTERO}

INCREMENTO_DECREMENTO    ("++"|"--")
ASIGNACION              ("+="|"-="|"*="
COMPARACION             ("=="|">="|"<"|">")
LOGICO                  ("&&"|"||"|"!")
ARITMETICO              ("+"|"-"|"*")

PARENTESIS_IZQUIERDO    "("
LLAVE_IZQUIERDA         "{"
CORCHETE_IZQUIERDO      "["
PUNTO_Y_COMA           ";"
COMA                   ","

ESPACIOS               [ \t\r\n]+
OTRO_CARACTER          .

%%

{PALABRA_RESERVADA} {
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

{DECIMAL} {
    printf("Clase: DECIMAL | Lexema: %s | Longitud: %zu\n",
           yytext, (size_t)yyleng);
}

{INCREMENTO_DECREMENTO} {
    printf("Clase: INCREMENTO_DECREMENTO | Lexema: %s\n", yytext);
}

{COMPARACION} {
    printf("Clase: OPERADOR_COMPARACION | Lexema: %s\n", yytext);
}

{LOGICO} {
    printf("Clase: OPERADOR_LOGICO | Lexema: %s\n", yytext);
}

{ARITMETICO} {
    printf("Clase: OPERADOR_ARITMETICO | Lexema: %s\n", yytext);
}

{PARENTESIS_IZQUIERDO} {
    printf("Clase: PARENTESIS_IZQUIERDO | Lexema: %s\n", yytext);
}


{LLAVE_IZQUIERDA} {
    printf("Clase: LLAVE_IZQUIERDA | Lexema: %s\n", yytext);
}


{CORCHETE_IZQUIERDO} {
    printf("Clase: CORCHETE_IZQUIERDO | Lexema: %s\n", yytext);
}


{PUNTO_Y_COMA} {
    printf("Clase: PUNTO_Y_COMA | Lexema: %s\n", yytext);
}

{COMA} {
    printf("Clase: COMA | Lexema: %s\n", yytext);
}

{ESPACIOS} {
    /* Omitir espacios, tabulaciones y saltos de linea. */
}

{OTRO_CARACTER} {
    printf("Caracter no reconocido: %s\n", yytext);
}

%%

int main(void)
{
    yylex();
    return EXIT_SUCCESS;
}
