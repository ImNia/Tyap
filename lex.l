%option noyywrap yylineno nodefault
%{
    #include <iostream>
    #include "y.tab.h"
    int ch;
    extern void yyerror (char *);
%}

digit[0-9]
letter[a-zA-Z]
delim[;]
brac[(){}]
ws[ \t\n]
operation[*/\+\-]
%%

("_"|{letter})("_"|{letter}|{digit})* { 
        ch += yyleng; 
        yylval.str = strdup(yytext); 
        return ID; }

[-+]?({digit}*\.{digit}+|{digit}+\.|{digit}+)([eE][-+]?{digit}+)?[flFL]? { 
        ch += yyleng; 
        yylval.str = strdup(yytext); 
        return NUM; }

"=" { ch += yyleng; return *yytext; }

"print" { ch += yyleng; return PRINT; }
"scan" { ch += yyleng; return SCAN; }

"int" { ch += yyleng; return INT; }
"double" { ch += yyleng; return DOUBLE; }

"while" { ch += yyleng; return WHILE; }
"if" { ch += yyleng; return IF; }
"else" { ch += yyleng; return ELSE;}

(">" | "<" | ">=" | "<=" | "!=" | "==") { ch += yyleng; return COMPARISON; }

{operation} { ch += yyleng; return OPERATION; }

{delim} { ch += yyleng; return *yytext; }
{brac} { ch += yyleng; return *yytext; }
{ws}+ { ch += yyleng; }

. { ch += yyleng; }

%%
