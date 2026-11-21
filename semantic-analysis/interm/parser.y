%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *mensaje);
extern FILE *yyin;

static struct { char nombre[64]; int tipo, funcion; } tabla[128];
static int n, globales, errores, numero, local;

static int buscar(const char *nombre, int inicio)
{
    for (int i = n - 1; i >= inicio; --i)
        if (strcmp(tabla[i].nombre, nombre) == 0) return i;
    return -1;
}
%}

%locations
%union { char nombre[64]; int tipo; }
%token CABECERA CONST INT DOUBLE RETURN MAIN PRINTF TEXTO ENTERO DECIMAL INVALIDO
%token <nombre> ID
%type <tipo> tipo literal expresion
%left '+' '-'
%left '*' '/' '%'

%{
static void declarar(const char *, int, int, int);
static int consultar(const char *, int, int);
static int operar(int, char, int, int);
%}

%%

programa:
      CABECERA constantes funciones inicio_main cuerpo
    ;

inicio_main:
      INT MAIN '(' ')'
        { local = 1; }
    ;

constantes:
      /* vacio */
    | constantes CONST tipo ID '=' literal ';'
        { declarar($4, $3, 0, @4.first_line); globales = n; }
    ;

funciones:
      /* vacio */
    | funciones funcion
    ;

funcion:
      cabecera '(' parametros_opt ')' cuerpo
        { n = globales; local = 0; /* Retirar los parametros y variables de esta funcion. */ }
    ;

cabecera:
      tipo ID
        { declarar($2, $1, 1, @2.first_line); globales = n; local = 1; }
    ;

parametros_opt:
      /* vacio */
    | parametros
    ;

parametros:
      variable
    | parametros ',' variable
    ;

variable:
      tipo ID
        { declarar($2, $1, 0, @2.first_line); }
    ;

tipo:
      INT
        { $$ = INT; }
    | DOUBLE
        { $$ = DOUBLE; }
    ;

cuerpo:
      '{' sentencias RETURN expresion ';' '}'
    ;

sentencias:
      /* vacio */
    | sentencias sentencia
    ;

sentencia:
      variable ';'
    | variable '=' expresion ';'
    | PRINTF '(' TEXTO mas_argumentos ')' ';'
    ;

argumentos_opt:
      /* vacio */
    | expresion mas_argumentos
    ;

mas_argumentos:
      /* vacio */
    | mas_argumentos ',' expresion
    ;

literal:
      ENTERO
        { $$ = INT; }
    | DECIMAL
        { $$ = DOUBLE; }
    ;

expresion:
      literal
        { $$ = $1; }
    | ID
        { $$ = consultar($1, 0, @1.first_line); }
    | ID '(' argumentos_opt ')'
        { $$ = consultar($1, 1, @1.first_line); }
    | '(' expresion ')'
        { $$ = $2; }
    | expresion '+' expresion
        { $$ = operar($1, '+', $3, @2.first_line); }
    | expresion '-' expresion
        { $$ = operar($1, '-', $3, @2.first_line); }
    | expresion '*' expresion
        { $$ = operar($1, '*', $3, @2.first_line); }
    | expresion '/' expresion
        { $$ = operar($1, '/', $3, @2.first_line); }
    | expresion '%' expresion
        { $$ = operar($1, '%', $3, @2.first_line); }
    ;

%%

static void declarar(const char *nombre, int tipo, int funcion, int linea)
{
    if (buscar(nombre, local ? globales : 0) >= 0) {
        fprintf(stderr, "Renglon %d: '%s' ya declarado.\n", linea, nombre);
        ++errores;
    } else {
        if (n == 128) { fputs("Tabla llena.\n", stderr); exit(2); }
        strcpy(tabla[n].nombre, nombre);
        tabla[n].tipo = tipo;
        tabla[n++].funcion = funcion;
    }
}

static int consultar(const char *nombre, int funcion, int linea)
{
    int i = buscar(nombre, 0);
    if (i >= 0 && tabla[i].funcion == funcion) return tabla[i].tipo;
    fprintf(stderr, "Renglon %d: '%s' %s.\n", linea, nombre,
            i < 0 ? "no declarado" : "usado con categoria incorrecta");
    ++errores;
    return 0;
}

static int operar(int a, char op, int b, int linea)
{
    int t = 0;
    if (a && b) {
        if (op == '%' && (a != INT || b != INT)) {
            fprintf(stderr, "Renglon %d: %% requiere dos enteros.\n", linea);
            ++errores;
        } else t = (a == DOUBLE || b == DOUBLE) ? DOUBLE : INT;
    }
    printf("E%d | renglon %d | %c | %s\n", ++numero, linea, op,
           t == INT ? "int" : t == DOUBLE ? "double" : "invalido");
    return t;
}

void yyerror(const char *mensaje)
{
    (void)mensaje;
    fprintf(stderr, "Renglon %d: error sintactico.\n", yylloc.first_line);
}

int main(int argc, char **argv)
{
    if (argc != 2) { fprintf(stderr, "Uso: %s prueba.c\n", argv[0]); return 1; }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror(argv[1]); return 1; }
    int fallo = yyparse();
    fclose(yyin);
    printf("Errores semanticos: %d\n", errores);
    return fallo || errores;
}
