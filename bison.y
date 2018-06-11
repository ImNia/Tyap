%{
	#include <iostream>
    #include "tree.h"
    #include "compiler.h"
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
 	extern char *yytext;
    extern int yylex();
	void yyerror(char *);
    Tree *root = new Tree("", _ROOT);
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
%left OPERATION_S
%left OPERATION_F
%nonassoc BRAC

%type<node> expr cycle defin comp prog tran
%type<str> ID NUM OPERATION_F OPERATION_S COMPARISON

%%
prog: cycle {
            root->addChild($1); } | 
        prog cycle { 
            root->addChild($2); }

cycle: PRINT expr ';' { 
            Tree *node = new Tree("print", _PRINT);
            node->addChild($2);
            $$ = node; } | 
        WHILE '(' comp ')' '{' tran '}' {
            Tree *node = new Tree("while", _WHILE);
            node->addChild($3);
            $3->addChild($6);
            $$ = node; } |
        IF '(' comp ')' '{' tran '}' { 
            Tree *node = new Tree("if", _IF);
            node->addChild($3);
            $3->addChild($6);
            $$ = node; } | 
        IF '(' comp ')' '{' tran '}' ELSE '{' tran '}' { 
            Tree *node = new Tree("if", _IFELSE);
            node->addChild($3);
            $3->addChild($6);
            $3->addChild($10);
            $$ = node; } | 
        SCAN expr ';' {
            Tree *node = new Tree("scan", _SCAN);
            node->addChild($2);
            $$ = node; } | 
        ID '=' expr ';' {
            Tree *node = new Tree("=", _ASSIGN);
            Tree *node_id = new Tree($1, 0);
            node->addChild(node_id);
            node->addChild($3);
            $$ = node; } |
        defin ID '=' expr ';' {
            Tree *node = new Tree("=", _ASSIGN);
            Tree *node_id = new Tree($2, _ID);
            node->addChild($1);
            node->addChild($4);
            $1->addChild(node_id);
            $$ = node; } |
        defin ID ';' {
            Tree *node = new Tree($2, _ID);
            $1->addChild(node);
            $$ = $1; }

tran: cycle { 
            Tree *node = new Tree(" ", _ROOT);
            node->addChild($1);
            $$ = node; } | 
        tran cycle { 
            $1->addChild($2);
            $$ = $1; }

defin: INT {
            Tree *node = new Tree("int", _INT);
            $$ = node;} | 
        DOUBLE {
            Tree *node = new Tree("double", _DOUBLE);
            $$ = node;}

expr: NUM { $$ = new Tree($1, _NUM); } | 
        ID { $$ = new Tree($1, _ID); } |
        expr OPERATION_S expr {
            Tree *node = new Tree($2, _MATH);
            node->addChild($1);
            node->addChild($3);
            $$ = node; } | 
        expr OPERATION_F expr {
            Tree *node = new Tree($2, _MATH);
            node->addChild($1);
            node->addChild($3);
            $$ = node; } | 
        '(' expr ')' { 
            $$ = $2; }

comp: expr COMPARISON expr {
            Tree *node = new Tree($2, _COMP);
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
	if(argc < 3)
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
    compile(root);
    std::string cmd = "fasm ./include/tmp.asm ";
    cmd += argv[2];
    std::system(cmd.c_str());
    cmd = "rm ./include/tmp.asm";
    std::system(cmd.c_str());
	return 0;
}
