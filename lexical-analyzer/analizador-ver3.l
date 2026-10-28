%option noyywrap

%{
#include <stdio.h>
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

"++"|"--" {
    printf("Clase: INCREMENTO_DECREMENTO | Lexema: %s\n", yytext);
}

"+="|"-="|"*="|"/="|"%="|"=" {
    printf("Clase: OPERADOR_ASIGNACION | Lexema: %s\n", yytext);
}

"=="|"!="|"<="|">="|"<"|">" {
    printf("Clase: OPERADOR_COMPARACION | Lexema: %s\n", yytext);
}

"&&"|"||"|"!" {
    printf("Clase: OPERADOR_LOGICO | Lexema: %s\n", yytext);
}

"+"|"-"|"*"|"/"|"%" {
    printf("Clase: OPERADOR_ARITMETICO | Lexema: %s\n", yytext);
}

"(" {
    printf("Clase: PARENTESIS_IZQUIERDO | Lexema: %s\n", yytext);
}

")" {
    printf("Clase: PARENTESIS_DERECHO | Lexema: %s\n", yytext);
}

"{" {
    printf("Clase: LLAVE_IZQUIERDA | Lexema: %s\n", yytext);
}

"}" {
    printf("Clase: LLAVE_DERECHA | Lexema: %s\n", yytext);
}

"[" {
    printf("Clase: CORCHETE_IZQUIERDO | Lexema: %s\n", yytext);
}

"]" {
    printf("Clase: CORCHETE_DERECHO | Lexema: %s\n", yytext);
}

";" {
    printf("Clase: PUNTO_Y_COMA | Lexema: %s\n", yytext);
}

"," {
    printf("Clase: COMA | Lexema: %s\n", yytext);
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
    return 0;
}
