%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *mensaje);
extern FILE *yyin;
static int errores = 0;
%}

%locations
%start programa

%token DEFINE FIN_DIRECTIVA
%token INT RETURN IDENTIFICADOR NUMERO

%left '+' '-'
%left '*' '/'

%%

programa:
    directivas funciones
;

directivas:
    /* vacío */
  | directivas directiva
;

directiva:
    DEFINE IDENTIFICADOR NUMERO FIN_DIRECTIVA
  | DEFINE error FIN_DIRECTIVA
    {
        puts("  Se esperaba: #define NOMBRE ENTERO");
        yyerrok;
    }
;

funciones:
    funcion
  | funciones funcion
;

funcion:
    INT IDENTIFICADOR '(' parametros ')' bloque
  | INT IDENTIFICADOR '(' error ')'
    {
        puts("  Parametros incorrectos. Ejemplo: (int a, int b)");
        yyerrok;
    }
    bloque
;

parametros:
    /* vacío */
  | lista_parametros
;

lista_parametros:
    INT IDENTIFICADOR
  | lista_parametros ',' INT IDENTIFICADOR
;

bloque:
    '{' sentencias '}'
;

sentencias:
    /* vacío */
  | sentencias sentencia
;

sentencia:
    INT IDENTIFICADOR '=' expresion ';'
  | RETURN expresion ';'
  | INT IDENTIFICADOR '=' error ';'
    {
        puts("  Se esperaba una expresion valida despues de '='.");
        yyerrok;
    }
  | RETURN error ';'
    {
        puts("  Se esperaba una expresion valida despues de return.");
        yyerrok;
    }
  | error ';'
    {
        puts("  Sentencia incorrecta. Se esperaba una declaracion o un return.");
        yyerrok;
    }
;

expresion:
    NUMERO
  | IDENTIFICADOR
  | IDENTIFICADOR '(' argumentos ')'
  | '(' expresion ')'
  | expresion '+' expresion
  | expresion '-' expresion
  | expresion '*' expresion
  | expresion '/' expresion
;

argumentos:
    /* vacío */
  | lista_argumentos
;

lista_argumentos:
    expresion
  | lista_argumentos ',' expresion
;

%%

void yyerror(const char *mensaje)
{
    (void)mensaje;
    ++errores;
    printf("Error sintactico en renglon %d, columna %d.\n",
           yylloc.first_line, yylloc.first_column);
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Uso: %s archivo.c\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }

    int resultado = yyparse();
    fclose(yyin);

    if (resultado != 0 || errores != 0)
        return 1;

    puts("Sintaxis correcta.");
    return 0;
}
