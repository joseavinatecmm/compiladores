%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *mensaje);
extern FILE *yyin;

/* ambito = -1: global; otro valor: indice de la funcion propietaria.
   Una firma conserva los tipos en orden: "ii" significa (int, int). */
static struct {
    char nombre[64], firma[33];
    int ambito, tipo, funcion;
} tabla[128];
static int n, actual = -1, errores, numero;

static void error(int linea, const char *nombre, const char *mensaje)
{
    fprintf(stderr, "Renglon %d: %s: %s.\n", linea, nombre, mensaje);
    ++errores;
}
%}

%locations
%union { char nombre[64]; char lista[33]; int tipo; }
%token CABECERA CONST INT DOUBLE RETURN MAIN PRINTF TEXTO ENTERO DECIMAL INVALIDO
%token <nombre> ID
%type <tipo> tipo literal expresion
%type <lista> argumentos argumentos_opt
%left '+' '-'
%left '*' '/' '%'

%{
static int declarar(const char *, int, int, int);
static int resolver(const char *, int, int);
static int llamar(const char *, const char *, int);
static void agregar(char *, int);
static void retorno(int, int);
static int operar(int, char, int, int);
%}

%%

programa:
      CABECERA constantes funciones inicio_main cuerpo
    ;

inicio_main:
      INT MAIN '(' ')'
        { actual = declarar("main", INT, 1, @2.first_line); }
    ;

constantes:
      /* vacio */
    | constantes CONST tipo ID '=' literal ';'
        { declarar($4, $3, 0, @4.first_line); }
    ;

funciones:
      /* vacio */
    | funciones funcion
    ;

funcion:
      cabecera '(' parametros_opt ')' cuerpo
        { actual = -1; }
    ;

cabecera:
      tipo ID
        { actual = declarar($2, $1, 1, @2.first_line); }
    ;

parametros_opt:
      /* vacio */
    | parametros
    ;

parametros:
      parametro
    | parametros ',' parametro
    ;

parametro:
      tipo ID
        {
            declarar($2, $1, 0, @2.first_line);
            agregar(tabla[actual].firma, $1);
        }
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
        { retorno($4, @3.first_line); }
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
        { $$[0] = 0; }
    | argumentos
        { strcpy($$, $1); }
    ;

argumentos:
      expresion
        { $$[0] = 0; agregar($$, $1); }
    | argumentos ',' expresion
        { strcpy($$, $1); agregar($$, $3); }
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
        { int i = resolver($1, 0, @1.first_line); $$ = i < 0 ? 0 : tabla[i].tipo; }
    | ID '(' argumentos_opt ')'
        { $$ = llamar($1, $3, @1.first_line); }
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

static int declarar(const char *nombre, int tipo, int funcion, int linea)
{
    for (int i = 0; i < n; ++i)
        if (tabla[i].ambito == actual && !strcmp(tabla[i].nombre, nombre)) {
            error(linea, nombre, "declaracion duplicada");
            if (!funcion) return i;
            /* Analizar el cuerpo duplicado sin alterar la primera firma. */
            nombre = "<funcion duplicada>";
            break;
        }
    if (n == 128) { fputs("Tabla llena.\n", stderr); exit(2); }
    strcpy(tabla[n].nombre, nombre);
    tabla[n].tipo = tipo;
    tabla[n].funcion = funcion;
    tabla[n].ambito = actual;
    return n++;
}

static int resolver(const char *nombre, int funcion, int linea)
{
    for (int i = n - 1; i >= 0; --i)
        if ((tabla[i].ambito == actual || tabla[i].ambito == -1)
            && !strcmp(tabla[i].nombre, nombre)) {
            if (tabla[i].funcion == funcion) return i;
            error(linea, nombre, "uso incorrecto como dato o funcion");
            return -1;
        }
    error(linea, nombre, "sin declaracion visible en este ambito");
    return -1;
}

static void agregar(char *lista, int tipo)
{
    size_t pos = strlen(lista);
    if (pos == 32) { fputs("Maximo: 32 parametros o argumentos.\n", stderr); exit(2); }
    lista[pos] = tipo == INT ? 'i' : tipo == DOUBLE ? 'd' : '?';
    lista[pos + 1] = 0;
}

/* Regla de aula: se admite int -> double, pero no double -> int implicito. */
static int llamar(const char *nombre, const char *args, int linea)
{
    int i = resolver(nombre, 1, linea);
    if (i < 0) return 0;
    const char *firma = tabla[i].firma;
    if (strlen(firma) != strlen(args)) {
        fprintf(stderr, "Renglon %d: %s espera %zu argumentos; recibio %zu.\n",
                linea, nombre, strlen(firma), strlen(args));
        ++errores;
        return 0;
    }
    for (int k = 0; args[k]; ++k)
        if (args[k] == 'd' && firma[k] == 'i') {
            fprintf(stderr, "Renglon %d: %s, argumento %d: se esperaba int; se recibio double.\n",
                    linea, nombre, k + 1);
            ++errores;
            return 0;
        }
    return tabla[i].tipo;
}

static void retorno(int tipo, int linea)
{
    if (tabla[actual].tipo == INT && tipo == DOUBLE)
        error(linea, tabla[actual].nombre, "return double en una funcion int");
}

/* Cero significa tipo invalido: evita repetir un error de un operando. */
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
