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
brac[()]
ws[ \t\n]
mul[*]
div[/]
add[\+]
sub[\-]

%%

("_"|{letter})("_"|{letter}|{digit})* { ch += yyleng; return ID;}

[-+]?({digit}*\.{digit}+|{digit}+\.|{digit}+)([eE][-+]?{digit}+)?[flFL]? { ch += yyleng; return NUM; }

":=" { ch += yyleng; return ASSIGN; }

{mul} { ch += yyleng; return MUL; }
{div} { ch += yyleng; return DIV; }
{add} { ch += yyleng; return ADD; }
{sub} { ch += yyleng; return SUB; }
{delim} { ch += yyleng; return *yytext; }
{brac} { ch += yyleng; return BRAC; }
{ws}+ { ch += yyleng; }

. { ch += yyleng; }

%%

