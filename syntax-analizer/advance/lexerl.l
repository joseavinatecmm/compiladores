%option noyywrap noinput nounput
%s DIRECTIVA

%{
#include "parser.tab.h"

static int renglon = 1, columna = 1;

#define YY_USER_ACTION                         \
    yylloc.first_line = renglon;               \
    yylloc.first_column = columna;             \
    columna += yyleng;
%}

ID      [A-Za-z_][A-Za-z0-9_]*
ENTERO  [0-9]+
SALTO   (\r\n|\n|\r)

%%

"#define"       { BEGIN(DIRECTIVA); return DEFINE; }
"int"           { return INT; }
"return"        { return RETURN; }
{ENTERO}        { return NUMERO; }
{ID}            { return IDENTIFICADOR; }

[ \t]+          { /* Omitir espacios. */ }
"//"[^\r\n]*    { /* Omitir comentario. */ }

{SALTO}         {
                    ++renglon;
                    columna = 1;
                    if (YY_START == DIRECTIVA) {
                        BEGIN(INITIAL);
                        return FIN_DIRECTIVA;
                    }
                }

<<EOF>>         {
                    yylloc.first_line = renglon;
                    yylloc.first_column = columna;
                    if (YY_START == DIRECTIVA) {
                        BEGIN(INITIAL);
                        return FIN_DIRECTIVA;
                    }
                    return 0;
                }

.               { return (unsigned char)yytext[0]; }

%%
