%{
	#include <iostream>
    #include "tree.h"
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
 	extern char *yytext;
    extern int yylex();
	void yyerror(char *);
    Tree *root = new Tree("", 0);
%}

%union{
    Tree *node;
    char *str;
}

%token ID
%token NUM
%token COMPARISON
%token PRINT SCAN INT DOUBLE WHILE IF ELSE
%right ASSIGN
%left OPERATION
%nonassoc BRAC

%type<node> expr cycle defin comp prog tran
%type<str> ID NUM OPERATION COMPARISON

%%
prog: cycle {
            root->addChild($1); } | 
        cycle prog { 
            root->addChild($2); }

cycle: PRINT expr ';' { 
            Tree *node = new Tree("print", 0);
            node->addChild($2);
            $$ = node; } | 
        WHILE '(' comp ')' '{' tran '}' {
            $3->addChild($6);
            $$ = $3; } |
        IF '(' comp ')' '{' tran '}' { 
            $3->addChild($6);
            $$ = $3; } | 
        IF '(' comp ')' '{' tran '}' ELSE '{' tran '}' { 
            $3->addChild($6);
            $3->addChild($10);
            $$ = $3; } | 
        SCAN expr ';' {
            Tree *node = new Tree("scan", 0);
            node->addChild($2);
            $$ = node; } | 
        ID '=' expr ';' {
            Tree *node = new Tree("=", 0);
            Tree *node_id = new Tree($1, 0);
            node->addChild(node_id);
            node->addChild($3);
            $$ = node; } |
        defin ID '=' expr ';' {
            Tree *node = new Tree("=", 0);
            Tree *node_id = new Tree($2, 0);
            node->addChild($1);
            node->addChild($4);
            $1->addChild(node_id);
            $$ = node; } |
        defin ID ';' {
            Tree *node = new Tree($2, 0);
            $1->addChild(node);
            $$ = $1; }

tran: cycle { 
            Tree *node = new Tree(" ", 0);
            node->addChild($1);
            $$ = node; } | 
        tran cycle { 
            $1->addChild($2);
            $$ = $1; }

defin: INT {
            Tree *node = new Tree("int", 0);
            $$ = node;} | 
        DOUBLE {
            Tree *node = new Tree("double", 0);
            $$ = node;}

expr: NUM { $$ = new Tree($1, 0); } | 
        ID { $$ = new Tree($1, 0); } | 
        '-' expr { 
            Tree *node = new Tree("-", 0);
            node->addChild($2);
            $$ = node; } | 
        expr OPERATION expr {
            Tree *node = new Tree($2, 0);
            node->addChild($1);
            node->addChild($3);
            $$ = node; } | 
        '(' expr ')' { 
            $$ = $2; }

comp: expr COMPARISON expr {
            Tree *node = new Tree($2, 0);
            node->addChild($1);
            node->addChild($3); 
            $$ = node; }

%%

void yyerror(char *errmsg)
{
	fprintf(stderr, "%s (%d, %d): %s\n", errmsg, yylineno, ch, yytext);
}

int main(int argc, char **argv)
{
	if(argc < 2)
	{
		printf("\nNot enough arguments. Please specify filename. \n");
		return -1;
	}
	if((yyin = fopen(argv[1], "r")) == NULL)
	{
		printf("\nCannot open file %s.\n", argv[1]);
		return -1;
	}

//    Tree *root = new Tree(" ", 1);
	ch = 1;
	yylineno = 1;
	yyparse();
	return 0;
}
