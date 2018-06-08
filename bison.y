%{
	#include <iostream>
    #include "tree.h"
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
 	extern char *yytext;
    extern char yylex();
	void yyerror(char *);

//    extern char yylval;
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

%type<node> try expr
%type<str> ID NUM

%%
prog: | cycle prog

cycle: PRINT expr ';' | 
        WHILE '(' comp ')' '{' tran '}' |
        IF '(' comp ')' '{' tran '}' | 
        IF '(' comp ')' '{' tran '}' ELSE '{' tran '}' | 
        SCAN expr ';' | 
        INT defin ';' | 
        DOUBLE defin ';' | 
        try

tran: cycle | 
        tran cycle

defin: ID '=' expr ';'| 
        ID

try: ID '=' expr ';' {
        Tree *node = new Tree("=", 0);
        Tree *node_id = new Tree($1, 0);
        node->addChild(node_id);
        node->addChild($3);
        $$ = node; }

expr: NUM { $$ = new Tree($1, 0); } | 
        ID { $$ = new Tree($1, 0); } | 
        '-' expr | expr OPERATION expr | '(' expr ')' 

comp: expr COMPARISON expr

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
