%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "AST.h"

#define ftypeName "Function"
#define typeName "Type"
#define in "Input"
#define out "Output"
#define blockName "block"


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
%token <string> SEMICOLON
%token <string> EQ
%token <number> NUMBER
%token <string> PLUS
%token <string> WRITE
%token <string> WRITELN
%token <string> MINUS
%token <string> MULT
%token <string> DIV
%token <string> OSB
%token <string> CSB
%token <string> OCB
%token <string> CCB
%token <string> OPAR
%token <string> CPAR
%token <string> READ

%type <ast> Program VarDeclList VarDecl Stmt StmtList Expr BinaryOp MathExpr Tail FunDeclList FunDecl Block

%left PLUS MINUS
%left MULT DIV

%start Program

%%

Program:	VarDeclList { 
						printf("\n--- Abstract Syntax Tree ---\n\n");
					 	print_tree($$, 0);
					}
;

VarDeclList: 
	| VarDecl VarDeclList	{ 	
								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* decl = malloc(sizeof(struct AST));
								decl = New_Tree("decl", $1, $2);
								$$ = decl;
							}	
;

FunDeclList:	FunDecl
	| FunDecl FunDeclList

;

FunDecl:	TYPE ID OPAR CPAR Block 	{
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											printf("\nRECOGNIZE RULE: Function Decl\n");
											AST* type = malloc(sizeof(AST));
											AST* id = malloc(sizeof(AST));
											type = New_Tree($1, NULL, NULL);
											id = New_Tree($2, NULL, $5);
											$$ = New_Tree(ftypeName, type, id);
										}

VarDecl: TYPE ID SEMICOLON	{ 
									printf("\n RECOGNIZED RULE: Variable declaration %s %s\n", $1, $2);
									
								  	// ---- SEMANTIC ACTIONS by PARSER ----
									struct AST* id = malloc(sizeof(struct AST));
									struct AST* type = malloc(sizeof(struct AST));
									id = New_Tree($2, NULL, NULL);
									type = New_Tree($1, NULL, NULL);
								    $$ = New_Tree(typeName, type, id);
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
											type_parent = New_Tree(typeName, type, array);
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
	| TYPE ID Tail						{
											/* ---- SEMANTIC ACTION by PARSER ---- */
											printf("\nRECOGNIZED RULE: Function Tail\n");
											AST* type = malloc(sizeof(AST));
											AST* id = malloc(sizeof(AST));
											type = New_Tree($1, NULL, NULL);
											id = New_Tree($2, NULL, $3);
											$$ = New_Tree(ftypeName, type, id);
										}
;

StmtList:	
	| Stmt StmtList		{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							$$ = New_Tree("stmt", $1, $2);
						}
;

Stmt:	READ ID SEMICOLON	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							AST* id = malloc(sizeof(AST));
							AST* read = malloc(sizeof(AST));
							id = New_Tree($2, NULL, NULL);
							read = New_Tree($1, NULL, NULL);
							$$ = New_Tree(in, read, id);
						}
	| WRITE ID 	SEMICOLON	{ 
								printf("\n RECOGNIZED RULE: WRITE statement\n");

								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* id = malloc(sizeof(struct AST));
								struct AST* write = malloc(sizeof(struct AST));
								id = New_Tree($2, NULL, NULL);
								write = New_Tree($1, NULL, NULL);
								$$ = New_Tree(out,write,id);
							}
	| WRITELN SEMICOLON		{
								printf("\n RECOGNIZED RULE: WRITELN statement\n");

								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* write = malloc(sizeof(struct AST));
								AST* ln = malloc(sizeof(AST));
								ln = New_Tree("\\n", NULL, NULL);
								write = New_Tree($1, NULL, NULL);
								$$ = New_Tree(out,write,ln);
							}
	| Expr SEMICOLON	{
							printf("\nTESTING: %s\n", $2);
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
| WRITE MathExpr 	{
					/* ---- SEMANTIC ACTIONS by PARSER ---- */
					AST* write = malloc(sizeof(AST));
					write = New_Tree($1, NULL, NULL);
					$$ = New_Tree(out, write, $2);
					
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
| ID	{
			/* ---- SEMANTIC ACTIONS by PARSER ---- */
			$$ = New_Tree($1, NULL, NULL);
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

Tail: OPAR CPAR Block 	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							printf("\nRECOGNIZE RULE: Function Decl\n");
							$$ = $3;
						}

Block: OCB VarDeclList StmtList CCB 	{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										printf("\nRECOGNIZED RULE: Function Block\n");
										AST* block = malloc(sizeof(AST));
										block = New_Tree("block", $2, $3);
										$$ = block;
									}

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
