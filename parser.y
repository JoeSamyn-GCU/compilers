%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "AST.h"

extern int yylex();
extern int yyparse();
extern int lines;
extern int chars;
extern FILE* yyin;

void yyerror(const char* s);
char currentScope[50]; // global or the name of the function
%}

%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

%token <string> TYPE
%token <string> ID
%token <char> SEMICOLON
%token <string> EQ
%token <number> NUMBER
%token <string> PLUS
%token <string> WRITE
%token <string> MINUS
%token <string> MULT
%token <string> DIV
%token <string> OSB
%token <string> CSB

%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

%type <ast> Program DeclList Decl VarDecl Stmt StmtList Expr BinaryOp MathExpr

%left PLUS MINUS
%left MULT DIV

%start Program

%%

Program: DeclList   { 
						$$ = $1;
					 	printf("\n--- Abstract Syntax Tree ---\n\n");
					 	print_tree($$, 0);
					}
;

DeclList:	Decl DeclList	{ 	
								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* decl = malloc(sizeof(struct AST));
								decl = New_Tree("decl", $1, $2);
							  	$$ = decl;
							}
	| Decl	{ 
				/* ---- SEMANTIC ACTIONS by PARSER ---- */
				struct AST* decl = malloc(sizeof(struct AST));
				decl = New_Tree("decl", $1, NULL);
				$$ = decl; 
			}
;

Decl:	VarDecl
	| StmtList {}
;

VarDecl:	TYPE ID SEMICOLON	{ 
									printf("\n RECOGNIZED RULE: Variable declaration %s %s\n", $1, $2);
									
								  	// ---- SEMANTIC ACTIONS by PARSER ----
									struct AST* id = malloc(sizeof(struct AST));
									struct AST* type = malloc(sizeof(struct AST));
									id = New_Tree($2, NULL, NULL);
									type = New_Tree($1, NULL, NULL);
								    $$ = New_Tree("Type", type, id);
									printf("Adding Variable Decl to tree: Type %s %s\nLINE %d CHAR %d\n", $1, $2, lines, chars);
								}
| TYPE ID OSB NUMBER CSB SEMICOLON 	{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										printf("RECOGNIZED RULE: Array Declaration\nTOKENS: %s %s %s %d %s\n", $1, $2, $3, $4, $5);
										struct AST* array = malloc(sizeof(struct AST));
										struct AST* type = malloc(sizeof(struct AST));
										struct AST* id = malloc(sizeof(struct AST));
										struct AST* num = malloc(sizeof(struct AST));
										struct AST* type_parent = malloc(sizeof(struct AST));
										char nums[100];
										sprintf(nums, "%d", $4);
										num = New_Tree(nums, NULL, NULL);
										id = New_Tree($2, NULL, NULL);
										type = New_Tree($1, NULL, NULL);
										array = New_Tree("Array", id, num);
										type_parent = New_Tree("Type", type, array);
										$$ = type_parent;
									}
| TYPE ID 							{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										/* ---- SYNTAX ERROR: no semicolon ---- */
										printf("\033[0;31m");
										printf("\nLine %d Character %d::SYNTAX ERROR::Missing semicolon after variable declaration\n", lines, chars);
										printf("\033[0m");
									}
| TYPE ID OSB NUMBER CSB			{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										/* ---- SYNTAX ERROR: no semicolon for array declaration ---- */
										printf("\033[0;31m");
										printf("\nLine %d Character %d::SYNTAX ERROR::Missing semicolon after array declaration\n", lines, chars);
										printf("\033[0m");
									}
| TYPE ID OSB CSB SEMICOLON			{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										/* ---- SYNTAX ERROR: no array size ---- */
										printf("\033[0;31m");
										printf("\nLine %d Character %d::SYNTAX ERROR::Array size was not declared\n", lines, chars);
										printf("\033[0m");
									}
;

StmtList:	
	| Stmt StmtList		{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							struct AST* s = malloc(sizeof(struct AST));
							s = New_Tree("stmt", $1, $2);
							$$ = s;
						}
;

Stmt:	SEMICOLON	{ printf("\nRECOGNIZED RULE: Semicolon\n");}
	| Expr SEMICOLON	{
							
							$$ = $1;
						}
;

Expr:	ID      { 
					printf("\n RECOGNIZED RULE: Simplest expression\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					struct AST* id = malloc(sizeof(struct AST));
					id = New_Tree($1, NULL, NULL);
					$$ = id;
				}
| ID EQ ID 	    { 
					printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					struct AST* id = malloc(sizeof(struct AST));
					struct AST* id_2 = malloc(sizeof(struct AST));
					id = New_Tree($1, NULL, NULL);
					id_2 = New_Tree($3, NULL, NULL);
					$$ = New_Tree("=",id, id_2);
				}
| WRITE ID 		{ 
					printf("\n RECOGNIZED RULE: WRITE statement\n");

					/* ---- SEMANTIC ACTIONS by PARSER ---- */
					struct AST* id = malloc(sizeof(struct AST));
					struct AST* write = malloc(sizeof(struct AST));
					id = New_Tree($2, NULL, NULL);
					write = New_Tree($1, NULL, NULL);
					$$ = New_Tree("print",write,id);
				}
| ID EQ MathExpr 	{
						/* ---- SEMANTIC ACTIONS by PARSER ---- */
						printf("\n RECOGNIZED RULE: ID EQ MathExpr\nTOKENS: %s %s %s\n", $1, $2, $3->nodeType);
						struct AST* id = malloc(sizeof(struct AST));
						struct AST* eq = malloc(sizeof(struct AST));
						id = New_Tree($1, NULL, NULL);
						eq = New_Tree("=", id, $3);
						$$ = eq;
					}
;


MathExpr:	MathExpr BinaryOp MathExpr 	{
									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									printf("\nRECOGNIZED RULE: Math Expression\nTOKENS: %s %s %s\n", $1->nodeType, $2->nodeType, $3->nodeType);
									$2->left = $1;
									$2->right = $3;

									$$ = $2;
								}
| NUMBER						{
									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									printf("\n RECOGNIZED RULE: NUMBER\nTOKENS: %d\n", $1);
									char num_s[100];
									sprintf(num_s, "%d", $1);
									$$ = New_Tree(num_s, NULL, NULL);;
								}
;

BinaryOp:	PLUS 	{ 
						printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| MINUS				{
						printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| MULT				{
						printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| DIV				{
						printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
;

%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n##### COMPILER STARTED #####\n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
