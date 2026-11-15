%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

int dentro_de_main = 0;
int llamada_en_main = 0;
%}

%token T_INCLUDE T_DEFINE T_LIBRERIA
%token T_INT T_MAIN T_RETURN
%token T_ID T_NUM T_ERROR_LEX

%left '+' '-'
%left '*' '/'

%start programa

%%

programa:
    lista_directivas lista_funciones funcion_main
    {
        if (!llamada_en_main) {
            yyerror("la función main() debe invocar al menos una función auxiliar");
            YYERROR;
        }
        printf("✅ Análisis sintáctico exitoso: programa en C válido (ACCEPT).\n");
    }
    ;

lista_directivas:
    directiva
    | lista_directivas directiva
    ;

directiva:
    T_INCLUDE T_LIBRERIA
    | T_DEFINE T_ID T_NUM
    | T_DEFINE T_ID '(' expresion ')'
    ;

lista_funciones:
    funcion_auxiliar
    | lista_funciones funcion_auxiliar
    ;

funcion_auxiliar:
    T_INT T_ID '(' lista_parametros ')' '{' cuerpo_funcion '}'
    ;

lista_parametros:
    /* vacío */
    | T_INT T_ID
    | lista_parametros ',' T_INT T_ID
    ;

cuerpo_funcion:
    lista_sentencias sentencia_return
    ;

funcion_main:
    T_INT T_MAIN '(' ')' '{' { dentro_de_main = 1; } cuerpo_main '}'
    ;

cuerpo_main:
    lista_sentencias sentencia_return
    ;

lista_sentencias:
    | lista_sentencias sentencia_simple
    | lista_sentencias llamada_funcion ';'
    ;

sentencia_simple:
    T_INT T_ID ';'
    | T_INT T_ID '=' expresion ';'
    | T_ID '=' expresion ';'
    ;

llamada_funcion:
    T_ID '(' lista_argumentos ')'
    {
        if (dentro_de_main) {
            llamada_en_main = 1;
        }
    }
    ;

lista_argumentos:
    /* vacío */
    | expresion
    | lista_argumentos ',' expresion
    ;

sentencia_return:
    T_RETURN expresion ';'
    ;

expresion:
    T_NUM
    | T_ID
    | llamada_funcion
    | expresion '+' expresion
    | expresion '-' expresion
    | expresion '*' expresion
    | expresion '/' expresion
    | '(' expresion ')'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Error de sintaxis: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            perror("❌ No se pudo abrir el archivo de entrada");
            return 1;
        }
        yyin = archivo;
    }

    printf("Analizando código fuente...\n");
    int resultado = yyparse();

    if (argc > 1 && yyin) {
        fclose(yyin);
    }

    return (resultado == 0) ? 0 : 1;
}
