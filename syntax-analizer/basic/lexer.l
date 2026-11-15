%{
#include <stdio.h>
#include "parser.tab.h" /* Archivo puente generado por Bison */
%}

%option noyywrap

%%

"#include"                  { return T_INCLUDE; }
"<"[a-zA-Z0-9_]+".h>"       { return T_LIBRERIA; }
"int"                       { return T_INT; }
"main"                      { return T_MAIN; }
"return"                    { return T_RETURN; }
"0"                         { return T_CERO; }

"("                         { return '('; }
")"                         { return ')'; }
"{"                         { return '{'; }
"}"                         { return '}'; }
";"                         { return ';'; }

[ \t\r\n]+                  { /* Ignorar espacios, tabulaciones y saltos de línea */ }

.                           { 
                              printf("Error léxico: carácter no reconocido '%s'\n", yytext); 
                              return T_ERROR_LEX; 
                            }

%%
