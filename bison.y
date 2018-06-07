%{
	#include <iostream>
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
	extern char *yytext;
    extern char yylex();
	void yyerror(char *);
%}

%token ID
%token NUM
%token COMPARISON
%token PRINT SCAN INT DOUBLE WHILE IF ELSE
%right ASSIGN
%left OPERATION
%nonassoc BRAC

%%
prog: | cycle prog

cycle: PRINT expr ';' | WHILE '(' comp ')' '{' tran '}' | IF '(' comp ')' '{' tran '}' | IF '(' comp ')' '{' tran '}' ELSE '{' tran '}' | SCAN expr ';' | INT defin ';' | DOUBLE defin ';'

tran: cycle | tran cycle

defin: ID '=' expr ';' | ID

expr: NUM | ID | '-' expr | expr OPERATION expr | '(' expr ')' 

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
	ch = 1;
	yylineno = 1;
	yyparse();
	return 0;
}
