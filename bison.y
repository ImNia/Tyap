%{
	#include <iostream>
    #include "tree.h"
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
 	extern char *yytext;
    extern int yylex();
	void yyerror(char *);

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

%type<node> try expr cycle defin comp prog 
%type<str> ID NUM

%%
prog: | cycle prog { 
            Tree *root = new Tree(" ", 0);
            Tree *node = new Tree($1, 0);
            root->addChild(node); }

cycle: PRINT expr ';' { 
            Tree *node = new Tree("print", 0);
            node->addChild($2);
            $$ = node; } | 
        WHILE '(' comp ')' '{' tran '}' {
            Tree *node = new Tree($3, 0);
            Tree *node_empty = new Tree(" ", 0);
            node_empty->addChild($6);
            node->addChild(node_empty);
            $$ = node; } |
        IF '(' comp ')' '{' tran '}' { 
            Tree *node = new Tree($3, 0);
            Tree *node_empty = new Tree(" ", 0);
            node_empty->addChild($6);
            node->addChild(node_empty);
            $$ = node; } | 
        IF '(' comp ')' '{' tran '}' ELSE '{' tran '}' { 
            Tree *node = new Tree($3, 0);
            Tree *node_empty = new Tree(" ", 0);
            Tree *node_else = new Tree(" ", 0);
            node_empty->addChild($6);
            node_else->addChild($10);
            node->addChild(node_empty);
            node->addChild(node_else);
            $$ = node; } | 
        SCAN expr ';' {
            Tree *node = new Tree("scan", 0);
            node->addChild($2);
            $$ = node; } | 
        INT defin ';' {
            Tree *node = new Tree("int", 0);
            node->addChild($2);
            $$ = node; } | 
        DOUBLE defin ';' {
            Tree *node = new Tree("double", 0);
            node->addChild($2);
            $$ = node; } | 
        try {
            Tree *node = new Tree($1, 0);
            $$ = node; }

tran: cycle { 
            Tree *node = new Tree(" ", 0);
            $$ = node; } | 
        tran cycle { 
            Tree *node = new Tree(" ", 0);
            Tree *node_two = new Tree(" ", 0);
            node->addChild(node_two);
            $$ = node; }

defin: ID '=' expr ';' {
            Tree *node = new Tree("=", 0);
            Tree *node_id = new Tree($1, 0);
            node->addChild(node_id);
            node->addChild($3);
            $$ = node; } | 
        ID { $$ = new Tree($1, 0); }

try: ID '=' expr ';' {
            Tree *node = new Tree("=", 0);
            Tree *node_id = new Tree($1, 0);
            node->addChild(node_id);
            node->addChild($3);
            $$ = node; }

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
            Tree *node = new Tree($2, 0);
            $$ = node; }

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
