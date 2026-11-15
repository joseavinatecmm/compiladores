%{
#include <stdio.h>
#include "parser.tab.h"
%}

%option noyywrap

%%

"#include"                  { return T_INCLUDE; }
"#define"                   { return T_DEFINE; }
"<"[a-zA-Z0-9_]+".h>"       { return T_LIBRERIA; }

"int"                       { return T_INT; }
"main"                      { return T_MAIN; }
"return"                    { return T_RETURN; }

[a-zA-Z_][a-zA-Z0-9_]*      { return T_ID; }
[0-9]+                      { return T_NUM; }

"="                         { return '='; }
"+"                         { return '+'; }
"-"                         { return '-'; }
"*"                         { return '*'; }
"/"                         { return '/'; }
"("                         { return '('; }
")"                         { return ')'; }
"{"                         { return '{'; }
"}"                         { return '}'; }
";"                         { return ';'; }
","                         { return ','; }

[ \t\r\n]+                  { /* Ignorar espacios y saltos de línea */ }

.                           {
                              fprintf(stderr, "Error léxico: carácter no reconocido '%s'\n", yytext);
                              return T_ERROR_LEX;
                            }

%%
