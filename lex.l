%option noyywrap yylineno nodefault
%{
    #include "tree.h"
    #include <iostream>
    #include "y.tab.h"
    int ch;
    extern void yyerror (char *);
    extern Hash *hash_table;
%}

digit[0-9]
letter[a-zA-Z]
delim[;]
brac[()]
ws[ \t\n]
operation_s[\+\-]
operation_f[*/]
%%
"{" { 
    ch += yyleng;
    hash_table->addHash();
    return *yytext; }
"}" { 
    ch += yyleng; 
    hash_table->deleteHash();
    return *yytext; }

"=" { ch += yyleng; return *yytext; }

"print" { ch += yyleng; return PRINT; }
"scan" { ch += yyleng; return SCAN; }

"int" { ch += yyleng; return INT; }
"double" { ch += yyleng; return DOUBLE; }

"while" { ch += yyleng; return WHILE; }
"if" { ch += yyleng; return IF; }
"else" { ch += yyleng; return ELSE;}

">" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }
"<" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }
">=" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }
"<=" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }
"==" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }
"!=" { ch += yyleng; yylval.str = strdup(yytext); return COMPARISON; }

{operation_s} { ch += yyleng; yylval.str = strdup(yytext); return OPERATION_S; }

{operation_f} { ch += yyleng; yylval.str = strdup(yytext); return OPERATION_F; }

("_"|{letter})("_"|{letter}|{digit})* { 
        ch += yyleng; 
        yylval.str = strdup(yytext); 
        return ID; }

[-+]?({digit}*\.{digit}+|{digit}+\.|{digit}+)([eE][-+]?{digit}+)?[flFL]? { 
        ch += yyleng; 
        yylval.str = strdup(yytext); 
        return NUM; }

{delim} { ch += yyleng; return *yytext; }
{brac} { ch += yyleng; return *yytext; }
{ws}+ { ch += yyleng; }

. { ch += yyleng; }

%%
