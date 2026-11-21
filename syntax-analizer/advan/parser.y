%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

int errores = 0;
%}

%error-verbose

%token T_INCLUDE    "directiva '#include'"
%token T_DEFINE     "directiva '#define'"
%token T_LIBRERIA   "librería '<archivo.h>'"
%token T_INT        "tipo 'int'"
%token T_MAIN       "'main'"
%token T_RETURN     "'return'"
%token T_ID         "identificador"
%token T_NUM        "número"
%token T_ERROR_LEX  "carácter inválido"

%left '+' '-'
%left '*' '/'

%start programa

%%

programa:
    lista_directivas lista_funciones funcion_main
    {
        if (errores == 0) {
            printf("✅ Programa en C válido (ACCEPT).\n");
        } else {
            fprintf(stderr, "⚠️ Análisis finalizado con %d error(es) sintáctico(s).\n", errores);
        }
    }
    ;

lista_directivas:
    directiva
    | lista_directivas directiva
    | lista_directivas T_INCLUDE { $$ = yylineno; } T_INCLUDE T_LIBRERIA
      {
          fprintf(stderr, "❌ Error línea  %d: falta el nombre de la librería '<archivo.h>' después de #include.\n", $3);
          errores++;
      }
    | lista_directivas T_INCLUDE { $$ = yylineno; } T_DEFINE T_ID T_NUM
      {
          fprintf(stderr, "❌ Error línea  %d: falta el nombre de la librería '<archivo.h>' después de #include.\n", $3);
          errores++;
      }
    | T_INCLUDE { $$ = yylineno; } T_INCLUDE T_LIBRERIA
      {
          fprintf(stderr, "❌ Error línea %d: falta el nombre de la librería '<archivo.h>' después de #include.\n", $2);
          errores++;
      }
    | T_INCLUDE { $$ = yylineno; } T_DEFINE T_ID T_NUM
      {
          fprintf(stderr, "❌ Error línea %d: falta el nombre de la librería '<archivo.h>' después de #include.\n", $2);
          errores++;
      }
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
    | T_ID { $$ = yylineno; } '(' lista_parametros ')' '{' cuerpo_funcion '}'
      {
          fprintf(stderr, "❌ Error línea %d: falta el tipo de retorno 'int' antes de la función.\n", $2);
          errores++;
      }
    | T_INT { $$ = yylineno; } '(' lista_parametros ')' '{' cuerpo_funcion '}'
      {
          fprintf(stderr, "❌ Errorlínea %d: falta el nombre (identificador) de la función después de 'int'.\n", $2);
          errores++;
      }
    | error '}'
      {
          yyerrok;
      }
    ;

lista_parametros:
    | T_INT T_ID
    | lista_parametros ',' T_INT T_ID
    | lista_parametros ',' T_ID
      {
          fprintf(stderr, "❌ Error línea %d: falta el tipo 'int' antes del parámetro.\n", yylineno);
          errores++;
      }
    ;

cuerpo_funcion:
    lista_sentencias sentencia_return
    ;

funcion_main:
    T_INT T_MAIN '(' ')' '{' cuerpo_main '}'
    | T_MAIN { $$ = yylineno; } '(' ')' '{' cuerpo_main '}'
      {
          fprintf(stderr, "❌ Error línea %d: falta el tipo de retorno 'int' antes de main().\n", $2);
          errores++;
      }
    | error '}'
      {
          yyerrok;
      }
    ;

cuerpo_main:
    lista_sentencias sentencia_return
    ;

lista_sentencias:
    | lista_sentencias sentencia_simple
    | lista_sentencias llamada_funcion ';'
    | lista_sentencias error ';'
      {
          yyerrok;
      }
    ;

sentencia_simple:
    T_INT T_ID ';'
    | T_INT T_ID '=' expresion ';'
    | T_ID '=' expresion ';'
    ;

llamada_funcion:
    T_ID '(' lista_argumentos ')'
    ;

lista_argumentos:
    | expresion
    | lista_argumentos ',' expresion
    ;

sentencia_return:
    T_RETURN expresion ';'
    | T_RETURN ';'
      {
          fprintf(stderr, "❌ Error sintáctico en línea %d: falta el valor o expresión de retorno en 'return'.\n", yylineno);
          errores++;
      }
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
    fprintf(stderr, "❌ Error sintáctico en línea %d (lexema '%s'): %s\n", yylineno, yytext, s);
    errores++;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            perror("No se pudo abrir el archivo");
            return 1;
        }
        yyin = archivo;
    }

    int resultado = yyparse();

    if (argc > 1 && yyin) fclose(yyin);
    return (resultado == 0 && errores == 0) ? 0 : 1;
}
