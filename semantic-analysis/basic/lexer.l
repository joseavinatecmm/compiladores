%option noyywrap noinput nounput yylineno
%{
#include <string.h>
#include "parser.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

%%
"int"                    { return INT; }
"main"                   { return MAIN; }
"return"                 { return RETURN; }
[A-Za-z_][A-Za-z0-9_]*   {
                            if ((size_t)yyleng >= sizeof yylval.nombre)
                                return ID_LARGO;
                            strcpy(yylval.nombre, yytext);
                            return ID;
                         }
[0-9]+                   { return NUM; }
[ \t\r\n]+               ;
"//"[^\r\n]*             ;
.                        { return (unsigned char)yytext[0]; }
<<EOF>>                  { yylloc.first_line = yylineno; return 0; }
%%
