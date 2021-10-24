%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <stack>
#include <vector>

#include "entry.h"
#include "symbolTable.h"
#include "symbolTable.cpp"
#include "semanticUtilities.h"
#include "semanticUtilities.cpp"

#include "AST.h"
#include "irgenerator.h"
#include "quadruples.h"

#define ftypeName "Function"
#define typeName "Type"
#define in "Input"
#define out "Output"
#define blockName "block"

Table* symbolTable = new Table();
Table* current = symbolTable; // pointer to SymbolTable
std::vector<Entry*> parameterVector;
int tempCounter = 1;

std::vector<Entry*> argumentVector;
int numArguments = 0;

extern int yylex();
extern int yyparse();
extern int lines;
extern int chars;
extern FILE* yyin;

int reg = 0;
bool debug = false;

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
%token <string> RETURN
%token <string> COMMA
%token <string> GTE 
%token <string> LTE
%token <string> GT
%token <string> LT
%token <string> EQEQ 
%token <string> NOTEQ
%token <string> WHILE
%token <string> IF
%token <string> ELSE
%token <string> OR
%token<string> AND


%type <ast> Program VarDeclList VarDecl Stmt StmtList Expr BinaryOp MathExpr Tail FunDecl Block Decl DeclList ParamDecl ParamDeclList RelExpr RelOp Matched Unmatched ArgList

%left PLUS MINUS
%left MULT DIV

%start Program

%%

Program: DeclList   { 
						/* ---- SEMANTIC ACTIONS by PARSER ---- */
						printf("\n--- Abstract Syntax Tree ---\n\n");
						print_tree($$, 0);

						// DUMP SYMBOL TABLE 
						printf("\n--- Symbol Table ---\n\n");
						current->printTables();
						printf("Total tables created: %i\n", tempCounter);
					}
;

DeclList: Decl { $$ = $1; }
| Decl DeclList	{ 	
					/* ---- SEMANTIC ACTIONS by PARSER ---- */
					insert_node_right($1, $2);
					$$ = $1;
				}	
;

Decl: VarDecl { $$ = $1; }
	| FunDecl { $$ = $1;}
;

FunDecl:	TYPE ID OPAR CPAR Block 	{
											// ---- SYMBOL TABLE ACTIONS by PARSER ----
											Entry* e = new Entry($2, $1);
											current->insertEntry(e);
											// if (current->parent != nullptr) {
											// 	current = current->parent;
											// 	std::cout << "MOVING UP A LEVEL" << std::endl;
											// }
											
											
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											if(debug)
												std::cout << "\nRECOGNIZE RULE: Function Decl\n";
											AST* type = (AST*)malloc(sizeof(AST));
											AST* id = (AST*)malloc(sizeof(AST));
											type = New_Tree($1, NULL, NULL);
											id = New_Tree($2, NULL, $5);
											$$ = New_Tree(ftypeName, type, id);
										}

VarDeclList: /* empty */ { $$ = NULL; }
| VarDecl VarDeclList	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							insert_node_right($1, $2);
							$$ = $1;
						}

VarDecl: TYPE ID SEMICOLON		{ 

								/* ---- Generate IR Code ---- */
								outfile << $2 << ": .skip 4\n";

								// ---- SYMBOL TABLE ACTIONS by PARSER ----
								Entry* e = new Entry($2, $1);
								current->insertEntry(e);
								
								// ---- SEMANTIC ACTIONS by PARSER ----
								struct AST* id = (AST*)malloc(sizeof(struct AST));
								struct AST* type = (AST*)malloc(sizeof(struct AST));
								id = New_Tree($2, NULL, NULL);
								type = New_Tree($1, NULL, NULL);
								$$ = New_Tree(typeName, type, id);
								if(debug)
									printf("Adding Variable Decl to tree: Type %s %s\nLINE %d CHAR %d\n", $1, $2, lines, chars);
							}
	| TYPE ID OSB NUMBER CSB SEMICOLON 	{
											// ---- SYMBOL TABLE ACTIONS by PARSER ----
											if ($4 < 1) {
												printf(FRED("SEMANTIC ERROR::Cannot declare array with size less than one\n"));
											}
											// name, dtype, scope, nelements
											Entry* e = new Entry($2, $1,"",$4);
											current->insertEntry(e);
											
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											if(debug)
												printf("RECOGNIZED RULE: Array Declaration\nTOKENS: %s %s %s %d %s\n", $1, $2, $3, $4, $5);
											struct AST* array = (AST*)malloc(sizeof(struct AST));
											struct AST* type = (AST*)malloc(sizeof(struct AST));
											struct AST* id = (AST*)malloc(sizeof(struct AST));
											struct AST* num = (AST*)malloc(sizeof(struct AST));
											struct AST* type_parent = (AST*)malloc(sizeof(struct AST));
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
											/* --- SYMBOL TABLE ACTIONS --- */
											Entry* e = new Entry($2, $1);
											while(!parameterVector.empty()) {
												e->params.push_back(parameterVector.back());
												//current->insertEntry(tempStack.top());
												parameterVector.pop_back();
											}
											current->insertEntry(e);
											/* ---- SEMANTIC ACTION by PARSER ---- */
											if(debug)
												printf("\nRECOGNIZED RULE: Function Tail\n");
											AST* type = (AST*)malloc(sizeof(AST));
											AST* id = (AST*)malloc(sizeof(AST));
											type = New_Tree($1, $3->left, NULL);
											id = New_Tree($2, NULL, $3->right);
											$$ = New_Tree(ftypeName, type, id);
										}
;

StmtList: Stmt	{ $$ = $1; }
	| Stmt StmtList		{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							insert_node_right($1, $2);
							$$ = $1;
						}
;

Stmt: /* empty */ { $$ = NULL; }
	| READ ID SEMICOLON	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							AST* id = (AST*)malloc(sizeof(AST));
							AST* read = (AST*)malloc(sizeof(AST));
							id = New_Tree($2, NULL, NULL);
							read = New_Tree($1, NULL, NULL);
							$$ = New_Tree(in, read, id);
						}
	| WRITE ID 	SEMICOLON	{ 
								if(debug)
									printf("\n RECOGNIZED RULE: WRITE statement\n");

								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* id = (AST*)malloc(sizeof(struct AST));
								struct AST* write = (AST*)malloc(sizeof(struct AST));
								id = New_Tree($2, NULL, NULL);
								write = New_Tree($1, NULL, NULL);
								$$ = New_Tree(out,write,id);
							}
	| WRITELN SEMICOLON		{
								if(debug)
									printf("\n RECOGNIZED RULE: WRITELN statement\n");

								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								struct AST* write = (AST*)malloc(sizeof(struct AST));
								AST* ln = (AST*)malloc(sizeof(AST));
								ln = New_Tree("\\n", NULL, NULL);
								write = New_Tree($1, NULL, NULL);
								$$ = New_Tree(out,write,ln);
							}
	| Expr SEMICOLON	{
							$$ = $1;
						}
	| RETURN MathExpr SEMICOLON	{
									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									$$ = New_Tree("return", NULL, $2);
								}
	| WHILE OPAR RelExpr CPAR Block		{
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											$$ = New_Tree($1, $3, $5);
										}
	| Matched 	{ $$ = $1; }
	| Unmatched { $$ = $1; }
;

Matched: IF OPAR RelExpr CPAR Matched ELSE Matched 	{
														/* ---- SEMANTIC ACTIONS by PARSER ---- */
														AST* cond = (AST*) malloc(sizeof(AST));
														AST* e = (AST*) malloc(sizeof(AST));
														AST* i = (AST*) malloc(sizeof(AST));

														e = New_Tree($6, $7, NULL);
														i = New_Tree($1, $3, $5);
														cond = New_Tree("COND", i, e);
														$$ = cond;
													}
  | Block	{ $$ = $1; }
;

Unmatched: IF OPAR RelExpr CPAR Block	{
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											if(debug)
												printf("\nRECOGNIZED RULE: IF STATEMENT\n");
											$$ = New_Tree($1, $3, $5);
										}
  | IF OPAR RelExpr CPAR Matched ELSE Unmatched	{
	  												/* ---- SEMANTIC ACTIONS by PARSER ---- */
														AST* cond = (AST*) malloc(sizeof(AST));
														AST* e = (AST*) malloc(sizeof(AST));
														AST* i = (AST*) malloc(sizeof(AST));

														e = New_Tree($6, $7, NULL);
														i = New_Tree($1, $3, $5);
														cond = New_Tree("COND", i, e);
														$$ = cond;
  												}
;

Expr:	ID  { 
				if(debug)
					printf("\n RECOGNIZED RULE: Simplest expression\n"); 
				// ---- SEMANTIC ACTIONS by PARSER ----
				struct AST* id = (AST*)malloc(sizeof(struct AST));
				id = New_Tree($1, NULL, NULL);
				$$ = id;
			}
| WRITE MathExpr 	{
					argumentVector.clear();
					/* ---- SEMANTIC ACTIONS by PARSER ---- */
					AST* write = (AST*)malloc(sizeof(AST));
					write = New_Tree($1, NULL, NULL);
					$$ = New_Tree(out, write, $2);
					
				}
| ID EQ MathExpr 	{
						/* --- SEMANTIC CHECKS --- */
						argumentVector.clear();
						/* ---- IR Code Generation ---- */
						reg++;
						outfile << "r" << reg << "=" << std::endl;
						print_tree($3, 0);

						/* ---- SEMANTIC ACTIONS by PARSER ---- */
						if(debug)
							std::cout << "\n RECOGNIZED RULE: ID EQ MathExpr\nTOKENS: " << $1 << " " << $2 << " " << $3->nodeType << std::endl;
						struct AST* id = (AST*)malloc(sizeof(struct AST));
						struct AST* eq = (AST*)malloc(sizeof(struct AST));
						id = New_Tree($1, NULL, NULL);
						eq = New_Tree("=", id, $3);
						$$ = eq;
					}
|  ID OPAR ArgList CPAR {
							/* --- SEMANTIC CHECKS --- */
							Entry* e = current->searchEntry($1);
							// check for correct parameters
							checkParameters(e, argumentVector);
							// Don't need to check return type since it is not assigned to anything
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							$$ = New_Tree($1, $3, NULL);
						}
| ID EQ ID OPAR ArgList CPAR 	{
							/* --- SEMANTIC CHECKS --- */
							Entry* e = current->searchEntry($1);
							Entry* f = current->searchEntry($3);
							// check for correct parameters
							checkParameters(f, argumentVector);
							if (e->dtype != f->dtype) {
							//if (e->dtype != f->returntype) {
								// fix this error wording
								printf(FRED("SEMANTIC ERROR::Function return cannot be assigned to ID\n"));
							}
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							AST* id_1 = (AST*) malloc(sizeof(AST));
							AST* fun = (AST*) malloc(sizeof(AST));
							id_1 = New_Tree($1, NULL, NULL);
							fun = New_Tree($3, $5, NULL);
							$$ = New_Tree($2, id_1, fun);
						}
| ID OSB MathExpr CSB EQ ID OPAR ArgList CPAR 	{
													/* ---- SEMANTIC ACTIONS by PARSER ---- */
													AST* id_1 = New_Tree($1, NULL, NULL);
													AST* arr = New_Tree("ARRAY", id_1, $3);
													AST* fun = New_Tree($6, $8, NULL);
													$$ = New_Tree($5, arr, fun);
												}
| ID EQ ID OSB NUMBER CSB 	{
								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								AST* id_1 = (AST*) malloc(sizeof(AST));
								AST* id_2 = (AST*) malloc(sizeof(AST));
								AST* arr = (AST*) malloc(sizeof(AST));
								AST* index = (AST*) malloc(sizeof(AST));

								id_1 = New_Tree($1, NULL, NULL);
								id_2 = New_Tree($3, NULL, NULL);
								index = New_Tree(std::to_string($5), NULL, NULL);
								arr = New_Tree("ARRAY_AT", id_2, index);
								
								$$ = New_Tree($2, id_1, arr);
							}
| ID OSB MathExpr CSB EQ MathExpr	{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										AST* id_1 = (AST*) malloc(sizeof(AST));
										AST* arr = (AST*) malloc(sizeof(AST));
										id_1 = New_Tree($1, NULL, NULL);
										arr = New_Tree("ARRAY", id_1, $3);

										$$ = New_Tree($5, arr, $6);
									}
;

ArgList: /* empty */ { $$ = NULL; }
| MathExpr	{
				/* --- SEMANTIC CHECKS (INSIDE FUNCTION CALL) --- */

			}
| MathExpr COMMA ArgList	{
								/* ---- SEMANTIC ACTIONS by PARSER ---- */
								$$ = New_Tree("ARG", $1, $3);
							}


MathExpr:	MathExpr BinaryOp MathExpr 	{
									/* ---- IR Code Generator ---- */
									outfile << $1->nodeType << " " << $2->nodeType << " " << $3->nodeType << std::endl;

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										std::cout << "\nRECOGNIZED RULE: Math Expression\nTOKENS: " << $1->nodeType << " " << 
								    $2->nodeType << " " << $3->nodeType << std::endl;
									$2->left = $1;
									$2->right = $3;

									$$ = $2;
								}
|	OPAR MathExpr CPAR	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							$$ = $2;
						}
| NUMBER						{
									/* --- SYMBOL TABLE CHECKS  --- */
									Entry* e = new Entry("Int", std::to_string($1));
									argumentVector.push_back(e);

									/* ---- IR CODE ---- */
									outfile << $1;

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										printf("\n RECOGNIZED RULE: NUMBER\nTOKENS: %d\n", $1);
									char num_s[100];
									sprintf(num_s, "%d", $1);
									$$ = New_Tree(num_s, NULL, NULL);;
								}
| ID	{
			/* --- SYMBOL TABLE CHECKS --- */
			Entry* e = current->searchEntry($1);
			if (e == nullptr && !parameterVector.empty()) { // TODO: check for parameters too!!!
				for (int i = 0; i < parameterVector.size(); i++) {
					if ($1 == parameterVector.at(i)->name) {
						std::cout<<"FOUND IT"<<std::endl;
						e = parameterVector.at(i);
						//current.insertEntry(parameterVector.at(i));
						break;
					}
				}
			}
			else if (e == nullptr) {
				printf(FRED("SEMANTIC ERROR::ID not declared in scope\n"));
			}
			else {
				std::cout<<e->name<<std::endl;
			}
			argumentVector.push_back(e);
			/*
			if (!parameterVector.empty()) {
				e = parameterVector.back();
				std::cout << "\n test. ID: "<< $1 << " temp: " << e->name << std::endl;
				if (e->name == $1) {
					std::cout<<"THEY ARE THE SAME!!!";
				}
				else {
					e = nullptr;
					std::cout<<"DIFF LOL";
				}
			}
			else {
				e = current->searchEntry($1);
			}

			if (e != nullptr) { // found entry
				argumentVector.push_back(e);
			}
			else { // Not declared in scope
				printf(FRED("SEMANTIC ERROR::ID not declared in scope\n"));
			}
			*/
			//Entry* e = new Entry("ID", (char*)$1);
			//argumentVector.push_back(e);

			/* ---- IR CODE ---- */
			outfile << $1;

			/* ---- SEMANTIC ACTIONS by PARSER ---- */
			if(debug)
				printf("\nRECOGNIZED RULE: ID\n");
			$$ = New_Tree($1, NULL, NULL);
		}
| ID OSB MathExpr CSB 	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							AST* id = (AST*) malloc(sizeof(AST));
							id = New_Tree($1, NULL, NULL);
							$$ = New_Tree("ARRAY", id, $3);
						}
;

BinaryOp:	PLUS 	{ 
						/* ---- IR CODE ---- */
						//outfile << $1;

						/* ---- SEMANTIC ACTIONS by PARSER ---- */
						if(debug)
							printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = (AST*)malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| MINUS				{
						if(debug)
							printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = (AST*)malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| MULT				{
						if(debug)
							printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = (AST*)malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
| DIV				{
						if(debug)
							printf("\n RECOGNIZED RULE: Operator\nTOKEN: %s\n", $1);
						struct AST* op = (AST*)malloc(sizeof(struct AST));
						op = New_Tree($1, NULL, NULL);
						$$ =  op;
					}
;

RelOp: GTE	{ $$ = New_Tree($1, NULL, NULL); }
| LTE 		{ $$ = New_Tree($1, NULL, NULL); }
| GT 		{ $$ = New_Tree($1, NULL, NULL); }
| LT		{ $$ = New_Tree($1, NULL, NULL); }
| EQEQ 		{ $$ = New_Tree($1, NULL, NULL); }
| NOTEQ 	{ $$ = New_Tree($1, NULL, NULL); }
;



RelExpr: MathExpr RelOp MathExpr	{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										if(debug)
											printf("\nRECOGNIZED RULE: Relational Expression\n");
										$$ = New_Tree($2->nodeType, $1, $3);
									}
| RelExpr AND RelExpr 	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}	
| RelExpr OR RelExpr	{
							/* ---- SEMANTIC ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| MathExpr { $$ = $1; }
;

Tail: OPAR ParamDeclList CPAR Block 	{
											// /* --- SYMBOL TABLE ACTIONS by PARSER --- */
											
											/* ---- SEMANTIC ACTIONS by PARSER ---- */
											if(debug)
												printf("\nRECOGNIZE RULE: Function Decl\n");
											$$ = New_Tree("params_holder", $2, $4);
										}
;

Block: OCB {
			//std::cout<<"MAKING NEW TABLE"<<std::endl;
			current = new Table(current);
			/*
			while(!tempStack.empty()) {
				current->insertEntry(tempStack.top());
				tempStack.pop();
			}
			*/
			tempCounter++;
			} VarDeclList StmtList {
				if (current->parent != nullptr) {
					//current->printEntries();
					current = current->parent;
					//std::cout << "MOVING UP A LEVEL" << std::endl;
				}
			} CCB 	{
										/* ---- SEMANTIC ACTIONS by PARSER ---- */
										if(debug)
											printf("\nRECOGNIZED RULE: Block\n");
										AST* block = (AST*)malloc(sizeof(AST));
										block = New_Tree("block", $3, $4);
										$$ = block;
									}
;

ParamDeclList: ParamDecl COMMA ParamDeclList 	{
													/* ---- SEMANTIC ACTIONS by PARSER ---- */
													insert_node_left($1, $3);
													$$ = $1;
												}
| ParamDecl		{ $$ = $1; }
;

ParamDecl: /* empty */ { $$ = NULL; }
| TYPE ID  	{
				/* --- SYMBOL TABLE ACTIONS by PARSER --- */
				Entry* e = new Entry($2, $1);
				parameterVector.push_back(e);
				//current->insertEntry(e);
				/* ---- SEMANTIC ACTIONS by PARSER ---- */
				struct AST* id = (AST*)malloc(sizeof(struct AST));
				struct AST* type = (AST*)malloc(sizeof(struct AST));
				id = New_Tree($2, NULL, NULL);
				type = New_Tree($1, NULL, NULL);
				$$ = New_Tree(typeName, type, id);
			}
| TYPE ID OSB CSB 	{
						/* --- SYMBOL TABLE ACTIONS by PARSER --- */
						Entry* e = new Entry($2, $1);
						parameterVector.push_back(e);
						/* ---- SEMANTIC ACTIONS by PARSER ---- */
						AST* id = New_Tree($2, NULL, NULL);
						AST* type = New_Tree($1, NULL, NULL);
						$$ = New_Tree("array", type, id);
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

	std::cout << "##### Opening IR Code File #####\n";
	openIrCodeFile();
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();

	std::cout << "#### Closing IR Code File ####\n";
	closeIrCodeFile();
	
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
