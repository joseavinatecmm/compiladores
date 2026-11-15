%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

/* Puntero global de entrada que utiliza el escáner de Flex */
extern FILE *yyin;
%}

/* Declaración de tokens (se exportan a parser.tab.h) */
%token T_INCLUDE
%token T_LIBRERIA
%token T_INT
%token T_MAIN
%token T_RETURN
%token T_CERO
%token T_ERROR_LEX

/* Símbolo inicial de la gramática */
%start programa

%%

programa:
    directiva_include funcion_main
    {
        printf("✅ Análisis sintáctico exitoso: programa en C válido (ACCEPT).\n");
    }
    ;

directiva_include:
    T_INCLUDE T_LIBRERIA
    ;

funcion_main:
    T_INT T_MAIN '(' ')' '{' sentencia_return '}'
    ;

sentencia_return:
    T_RETURN T_CERO ';'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Error de sintaxis: el programa no cumple con la estructura esperada (%s).\n", s);
}

int main(int argc, char **argv) {
    /* Si se pasa un archivo como parámetro, redirigimos yyin a ese archivo */
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            perror("❌ No se pudo abrir el archivo de entrada");
            return 1;
        }
        yyin = archivo;
    } else {
        printf("Modo entrada estándar (escribe el código y presiona Ctrl+D al finalizar):\n");
    }

    printf("Analizando entrada...\n");
    int resultado = yyparse();

    /* Cerramos el archivo si se abrió desde argumentos */
    if (argc > 1 && yyin) {
        fclose(yyin);
    }

    return (resultado == 0) ? 0 : 1;
}
