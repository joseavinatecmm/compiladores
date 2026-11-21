%option noyywrap noinput nounput yylineno
%{
#include <string.h>
#include "parser.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylineno;
%}

ID      [a-zA-Z_][a-zA-Z_0-9]*
D       [0-9]
EXP     [eE][+-]?{D}+
REAL    ({D}+"."{D}*|"."{D}+)({EXP})?|{D}+{EXP}

%%
"#include"[ \t]*"<stdio.h>"   return CABECERA;
"int"                         return INT;
"double"                      return DOUBLE;
"const"                       return CONST;
"return"                      return RETURN;
"main"                        return MAIN;
"printf"                      return PRINTF;
{REAL}                        return DECIMAL;
{D}+                          return ENTERO;
{ID}                          {
                                  if (yyleng >= sizeof yylval.nombre) return INVALIDO;
                                  strcpy(yylval.nombre, yytext);
                                  return ID;
                              }
\"([^\"\\\n]|\\.)*\"            return TEXTO;
[ \t\r\n]+                    ;
"//"[^\n]*                    ;
.                             return (unsigned char)yytext[0];
%%
