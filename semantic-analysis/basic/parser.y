%{
#include <stdio.h>
#include <string.h>

int yylex(void);
void yyerror(const char *mensaje);
extern FILE *yyin;

static char tabla[100][64];
static int cantidad = 0;
static int errores = 0;

static int existe(const char *nombre)
{
    for (int i = 0; i < cantidad; ++i)
        if (strcmp(tabla[i], nombre) == 0)
            return 1;
    return 0;
}

static void declarar(const char *nombre, int linea)
{
    if (existe(nombre)) {
        fprintf(stderr, "Renglon %d: '%s' ya fue declarada.\n", linea, nombre);
        ++errores;
    } else if (cantidad == 100) {
        fprintf(stderr, "Renglon %d: tabla llena; no se registro '%s'.\n", linea, nombre);
        ++errores;
    } else {
        strcpy(tabla[cantidad++], nombre);
    }
}

static void usar(const char *nombre, int linea)
{
    if (!existe(nombre)) {
        fprintf(stderr, "Renglon %d: '%s' no esta declarada.\n", linea, nombre);
        ++errores;
    }
}
%}

%locations
%union { char nombre[64]; }
%token INT MAIN RETURN NUM ID_LARGO
%token <nombre> ID

%%

programa: INT MAIN '(' ')' '{' declaraciones RETURN valor ';' '}' ;

declaraciones:
    
  | declaraciones declaracion
;

declaracion:
    nombre_declarado ';'
  | nombre_declarado '=' valor ';'
;

nombre_declarado:
    INT ID  { declarar($2, @2.first_line); }
;

valor:
    NUM
  | ID      { usar($1, @1.first_line); }
;

%%

void yyerror(const char *mensaje)
{
    (void)mensaje;
    fprintf(stderr, "Renglon %d: %s.\n", yylloc.first_line,
            yychar == ID_LARGO ? "identificador mayor de 63 caracteres" : "error de sintaxis");
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Uso: %s archivo.c\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror(argv[1]); return 1; }

    int resultado = yyparse();
    fclose(yyin);
    if (resultado != 0) return 1;

    printf("Errores semanticos: %d\n", errores);
    return errores != 0;
}
