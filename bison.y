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
%right ASSIGN
%left ADD SUB
%left MUL DIV
%nonassoc BRAC

%%
prog: expr | prog expr 
expr: ID ASSIGN logexp ';' |
        error ';'
logexp: [lodexp] BRAC logexp BRAC [logexp] { printf("bracket\n"); } |
        logexp MUL logexp { printf("mul\n"); } |
		logexp DIV logexp { printf("div\n"); } |
		logexp ADD logexp { printf("add\n"); } |
		logexp SUB logexp { printf("sub\n"); } |
        d
d: ID { printf("id\n"); }
    | NUM { printf("num\n"); }

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
