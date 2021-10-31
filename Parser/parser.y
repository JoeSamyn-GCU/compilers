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
#include "irgen.h"
#include "quadruples.h"

#define ftypeName "Function"
#define typeName "Type"
#define in "Input"
#define out "Output"
#define blockName "block"
#define integer "int"


Table* symbolTable = new Table();
Table* current = symbolTable; // pointer to SymbolTable
std::vector<Entry*> parameterVector;
int tempCounter = 1;

std::vector<Entry*> argumentVector;
int numArguments = 0;

std::string returnTypeVar = "";

extern int yylex();
extern int yyparse();
extern int lines;
extern int chars;
extern FILE* yyin;

int reg = 0;
bool debug = false;
bool is_global = true;
bool is_while = false;
int lable_counter = 0;
std::string curr_label = "";

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


%type <ast> Program VarDeclList VarDecl Stmt StmtList Expr MathExpr Tail FunDecl Block Decl DeclList ParamDecl ParamDeclList RelExpr Matched Unmatched ArgList

%left PLUS MINUS
%left MULT DIV

%start Program

%%

Program: {
			IrGen::ofile << ".data" << std::endl; 
			IrGen::ofile << "ln: .asciiz \"\\n\"" << std::endl; 

		} 
DeclList   { 
				/* ---- AST ACTIONS by PARSER ---- */
				printf("\n--- Abstract Syntax Tree ---\n\n");
				print_tree($2, 0);

				// DUMP SYMBOL TABLE 
				printf("\n--- Symbol Table ---\n\n");
				current->printTables();
				printf("Total tables created: %i\n", tempCounter);
					}
											;

DeclList: Decl { $$ = $1; }
| Decl DeclList	{ 	
					/* ---- AST ACTIONS by PARSER ---- */
					insert_node_right($1, $2);
					$$ = $1;
				}	
;

Decl: VarDecl { $$ = $1; }
	| FunDecl { $$ = $1;}
;

FunDecl:	TYPE ID OPAR 	{
								if(is_global){
									is_global = false;
									IrGen::ofile << "\n.text\n";
								}
								IrGen::ofile << $2 << ": \n";
								IrGen::scope_counter++;
								
							} CPAR Block 	{
												// ---- IR CODE GENERATION ----
												std::cout << $2 << std::endl;
												if(strcmp($2, "main") != 0)
													IrGen::printIrCodeCommand("jr", "$ra", "", "");
												IrGen::ofile << std::endl;

												// ---- SYMBOL TABLE ACTIONS by PARSER ----
												current = new Table(current);
												Entry* e = new Entry($2, $1);
												current->insertEntry(e);

												// ---- SEMANTIC ACTIONS by PARSER ----
												if( $1 != returnTypeVar && !strcmp($1, "void") ) 
													std::cout << FRED("ERROR: Function type does not match RETURN type") << std::endl;
												
												returnTypeVar = "";
												
												/* ---- AST ACTIONS by PARSER ---- */
												if(debug)
													std::cout << "\nRECOGNIZE RULE: Function Decl\n";
												AST* type = (AST*)malloc(sizeof(AST));
												AST* id = (AST*)malloc(sizeof(AST));
												type = New_Tree($1, NULL, NULL);
												id = New_Tree($2, NULL, $6);
												$$ = New_Tree(ftypeName, type, id);

												IrGen::scope_counter--;
											}
;

VarDeclList: /* empty */ { $$ = NULL; }
| VarDecl VarDeclList	{
							/* ---- AST ACTIONS by PARSER ---- */
							insert_node_right($1, $2);
							$$ = $1;
						}
;

VarDecl: TYPE ID SEMICOLON		{ 

								/* ---- Generate IR Code ---- */
								if(is_global)
									IrGen::ofile << $2 << ": .word 4\n";
								else{
									std::string reg = IrGen::getRegister();
									IrGen::mapVarToReg($2, reg);
									IrGen::printIrCodeCommand("li", "0", reg, "");
								}

								// ---- SYMBOL TABLE ACTIONS by PARSER ----
								Entry* e = new Entry($2, $1);
								current->insertEntry(e);
								
								// ---- AST ACTIONS by PARSER ----
								struct AST* id = (AST*)malloc(sizeof(struct AST));
								struct AST* type = (AST*)malloc(sizeof(struct AST));
								id = New_Tree($2, NULL, NULL);
								type = New_Tree($1, NULL, NULL);
								$$ = New_Tree(typeName, type, id);
								if(debug)
									printf("Adding Variable Decl to tree: Type %s %s\nLINE %d CHAR %d\n", $1, $2, lines, chars);
							}
	| TYPE ID OSB NUMBER CSB SEMICOLON 	{
											/* ---- SYMBOL TABLE ACTIONS by PARSER ---- */
											if ($4 < 1) {
												printf(FRED("SEMANTIC ERROR::Cannot declare array with size less than one\n"));
											}
											// name, dtype, scope, nelements
											Entry* e = new Entry($2, $1,"",$4);
											current->insertEntry(e);
											
											/* ---- AST ACTIONS by PARSER ---- */
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
											/* ---- SYNTAX ERROR: no semicolon ---- */
											printf("\033[0;31m");
											printf("\nLine %d Character %d::SYNTAX ERROR::Missing semicolon after variable declaration\n", lines, chars);
											printf("\033[0m");
										}
	| TYPE ID OSB NUMBER CSB			{
											/* ---- SYNTAX ERROR: no semicolon for array declaration ---- */
											printf("\033[0;31m");
											printf("\nLine %d Character %d::SYNTAX ERROR::Missing semicolon after array declaration\n", lines, chars);
											printf("\033[0m");
										}
	| TYPE ID OSB CSB SEMICOLON			{
											/* ---- SYNTAX ERROR: no array size ---- */
											printf("\033[0;31m");
											printf("\nLine %d Character %d::SYNTAX ERROR::Array size was not declared\n", lines, chars);
											printf("\033[0m");
										}
	| TYPE ID Tail						{
											/* --- SYMBOL TABLE ACTIONS --- */
											Entry* e = new Entry($2, "", "", 0, 0, {}, $1);
											while(!parameterVector.empty()) {
												e->params.push_back(parameterVector.back());
												//current->insertEntry(tempStack.top());
												parameterVector.pop_back();
											}
											current->insertEntry(e);

											if( e->returntype != returnTypeVar ) 
												std::cout << FRED("ERROR: Function type does not match RETURN type") << std::endl;

											returnTypeVar = "";


											/* ---- AST ACTION by PARSER ---- */
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
							/* ---- AST ACTIONS by PARSER ---- */
							insert_node_right($1, $2);
							$$ = $1;
						}
;

Stmt: /* empty */ { $$ = NULL; }
	| READ ID SEMICOLON	{
							/* ---- AST ACTIONS by PARSER ---- */
							AST* id = (AST*)malloc(sizeof(AST));
							AST* read = (AST*)malloc(sizeof(AST));
							id = New_Tree($2, NULL, NULL);
							read = New_Tree($1, NULL, NULL);
							$$ = New_Tree(in, read, id);
						}
	| WRITE ID 	SEMICOLON	{ 
								/* ---- Code Generation ---- */
								// Check what type the ID is
								Entry* e = current->searchEntry($2);
								
								// Get the id register or load global var into memory
								std::string reg = IrGen::getMappedRegister($2);
								if(reg == ""){
									reg = IrGen::loadGlobal($2);
								}

								// Print integer using MIPS, no new line
								if(e->dtype == integer){
									IrGen::printIrCodeCommand("li", "$v0,", "1", "");
									IrGen::printIrCodeCommand("move", "$a0", reg, "");
									IrGen::syscall();
								}
								else if(e->dtype == "char"){
									IrGen::printIrCodeCommand("li", "$v0,", "11", "");
									IrGen::printIrCodeCommand("move", "$a0", reg, "");
									IrGen::syscall();
								}

								/* ---- DEBUGGING ---- */
								if(debug)
									printf("\n RECOGNIZED RULE: WRITE statement\n");

								/* ---- AST ACTIONS by PARSER ---- */
								struct AST* id = (AST*)malloc(sizeof(struct AST));
								struct AST* write = (AST*)malloc(sizeof(struct AST));
								id = New_Tree($2, NULL, NULL);
								write = New_Tree($1, NULL, NULL);
								$$ = New_Tree(out,write,id);
							}
	| WRITELN SEMICOLON		{
								/* ---- Code Generator ---- */
								IrGen::ofile << "li $v0, 4\nla $a0, ln\nsyscall\n";

								if(debug)
									printf("\n RECOGNIZED RULE: WRITELN statement\n");

								/* ---- AST ACTIONS by PARSER ---- */
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
									// required for semantic checks
									argumentVector.clear();
									returnTypeVar = "int";

									/* ---- AST ACTIONS by PARSER ---- */
									$$ = New_Tree("return", NULL, $2);
								}
	| WHILE { is_while = true; } OPAR RelExpr CPAR Block		{
											/* ---- Code Generation ---- */
											std::string label = ".L" + std::to_string(lable_counter);
											IrGen::printJump(label);

											lable_counter++;
											std::cout << "Label: " << lable_counter << std::endl;
											label = ".L" + std::to_string(lable_counter);
											IrGen::printLabel(label);
											is_while = false;
											lable_counter++;

											/* ---- AST ACTIONS by PARSER ---- */
											$$ = New_Tree($1, $4, $6);
										}
	| Matched 	{ $$ = $1; }
	| Unmatched { $$ = $1; }
;

Matched: IF OPAR RelExpr CPAR Matched ELSE {IrGen::printLabel(".L" + std::to_string(lable_counter)); } Matched 	{
																														/* ---- GENERATE IR CODE ---- */
																														IrGen::printLabel(curr_label);
																														lable_counter++;

																														/* ---- AST ACTIONS by PARSER ---- */
																														AST* cond = (AST*) malloc(sizeof(AST));
																														AST* e = (AST*) malloc(sizeof(AST));
																														AST* i = (AST*) malloc(sizeof(AST));

																														e = New_Tree($6, $8, NULL);
																														i = New_Tree($1, $3, $5);
																														cond = New_Tree("COND", i, e);
																														$$ = cond;
																													}
  | Block	{ 
	  			/* ---- GENERATE IR CODE ---- */
				curr_label = ".L" + std::to_string(lable_counter+1);
				IrGen::printIrCodeCommand("j", curr_label, "\n", "");

	  			$$ = $1; 
			}
;

Unmatched: IF OPAR RelExpr CPAR Block	{
											/* ---- GENERATE IR CODE ---- */
											std::cout << "Label Counter: " << lable_counter << std::endl;
											curr_label = ".L" + std::to_string(lable_counter);
											IrGen::printIrCodeCommand("j", curr_label, "", "");
											IrGen::printLabel(curr_label);
											curr_label = "";

											/* ---- AST ACTIONS by PARSER ---- */
											if(debug)
												printf("\nRECOGNIZED RULE: IF STATEMENT\n");
											
											$$ = New_Tree($1, $3, $5);
										}
  | IF OPAR RelExpr CPAR Matched ELSE Unmatched	{
	  												/* ---- AST ACTIONS by PARSER ---- */
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
				argumentVector.clear();
				/* ---- AST ACTIONS by PARSER ---- */
				struct AST* id = (AST*)malloc(sizeof(struct AST));
				id = New_Tree($1, NULL, NULL);
				$$ = id;
			}
| WRITE MathExpr 	{
						/* ---- Code Generator ---- */
						IrGen::printIrCodeCommand("li", "$v0,", "1", "");
						IrGen::printIrCodeCommand("move", "$a0", $2->reg, "");
						IrGen::syscall();

						argumentVector.clear();

						/* ---- AST ACTIONS by PARSER ---- */
						AST* write = (AST*)malloc(sizeof(AST));
						write = New_Tree($1, NULL, NULL);
						$$ = New_Tree(out, write, $2);
						
					}
| ID EQ MathExpr 	{
						
						argumentVector.clear();

						/* --- SEMANTIC CHECKS --- */
						checkExistance(current, $1, parameterVector);
						checkIntType(current, $1);
						

						/* ---- AST ACTIONS by PARSER ---- */
						if(debug)
							std::cout << "\n RECOGNIZED RULE: ID EQ MathExpr\nTOKENS: " << $1 << " " << $2 << " " << $3->nodeType << std::endl;
						struct AST* id = (AST*)malloc(sizeof(struct AST));
						struct AST* eq = (AST*)malloc(sizeof(struct AST));
						id = New_Tree($1, NULL, NULL);
						eq = New_Tree("=", id, $3);
						$$ = eq;
					}
| ID EQ ID 	{
				/* --- SEMANTIC CHECKS --- */
				checkExistance(current, $1, parameterVector);
				checkExistance(current, $3, parameterVector);
				std::cout << "HIT ID" << std::endl;

				/* ---- IR Code Generation ---- */
				// TODO: fix this to check both global variables exist
				std::string reg_1 = IrGen::getMappedRegister($1);
				std::string reg_2 = IrGen::getMappedRegister($3);
				// Both global vars
				if(reg_1 == "" && reg_2 == ""){
					reg_2 = IrGen::getRegister();
					std::string gp = "($gp)";
					std::string id($1);
					std::string id_2($3);
					IrGen::printIrCodeCommand("lw", id_2.append(gp) + ",", reg_2, "");
					IrGen::printIrCodeCommand("sw", reg_2 + ",", id.append(gp), "");
					int reg_1_index = reg_2[2] - 48;
					IrGen::registers[reg_1_index] = false;
				}
				else if (reg_1 != "" && reg_2 == ""){
					std::string gp = "($gp)";
					std::string id_2($3);
					IrGen::printIrCodeCommand("li", id_2.append(gp) + ",", reg_1, "");
				}
				else if (reg_1 == "" && reg_2 != ""){
					std::string gp = "($gp)";
					std::string id_1($1);
					IrGen::printIrCodeCommand("li", id_1.append(gp) + ",", reg_2, "");
				}else{
					IrGen::printIrCodeCommand("li", reg_2 + ",", reg_1, "");
				}

				/* ---- AST ACTIONS by PARSER ---- */
				if(debug)
					std::cout << "\n RECOGNIZED RULE: ID EQ ID\nTOKENS: " << $1 << " " << $2 << " " << $3 << std::endl;
				struct AST* id_1 = (AST*)malloc(sizeof(struct AST));
				struct AST* id_2 = (AST*)malloc(sizeof(struct AST));
				struct AST* eq = (AST*)malloc(sizeof(struct AST));
				id_1 = New_Tree($1, NULL, NULL);
				id_2 = New_Tree($3, NULL, NULL);
				eq = New_Tree("=", id_1, id_2);
				$$ = eq;
			}
| ID EQ NUMBER 	{
					/* --- SEMANTIC CHECKS --- */
					argumentVector.clear();
					checkExistance(current,$1, parameterVector);
					/* ---- IR Code Generation ---- */
					std::string id_reg = IrGen::getMappedRegister($1);
					// This is assumed to be a global variable 
					if(id_reg == ""){
						id_reg = IrGen::getRegister();
						IrGen::printIrCodeCommand("li", std::to_string($3).append(","), id_reg, "");
						IrGen::storeGlobal(id_reg, $1);
					}

					std::cout << "HIT NUM" << std::endl;

					/* ---- AST ACTIONS by PARSER ---- */
					if(debug)
						std::cout << "\n RECOGNIZED RULE: ID EQ ID\nTOKENS: " << $1 << " " << $2 << " " << $3 << std::endl;
					struct AST* id_1 = (AST*)malloc(sizeof(struct AST));
					struct AST* num = (AST*)malloc(sizeof(struct AST));
					struct AST* eq = (AST*)malloc(sizeof(struct AST));
					id_1 = New_Tree($1, NULL, NULL);
					num = New_Tree(std::to_string($3), NULL, NULL);
					eq = New_Tree("=", id_1, num);
					$$ = eq;
				}
|  ID OPAR ArgList CPAR {
							/* ---- Code Generator ---- */
							IrGen::printIrCodeCommand("jal", $1, "", "");

							/* --- SEMANTIC CHECKS --- */
							std::cout<<"Got to this point: Checking parameters for function"<<std::endl;
							Entry* e = current->searchEntry($1);
							// check for correct parameters
							checkParameters(e, argumentVector);
							argumentVector.clear();
							// Don't need to check return type since it is not assigned to anything

							/* ---- AST ACTIONS by PARSER ---- */
							$$ = New_Tree($1, $3, NULL);
						}

	| ID EQ ID OPAR ArgList CPAR 	{
										/* --- SEMANTIC CHECKS --- */
										// check if first ID exists in table or parameters
										Entry* e = checkExistance(current, $1, parameterVector);
										Entry* f = checkExistance(current, $3, parameterVector);
										
										if( e == nullptr ) 
											std::cout << FRED("ERROR: ID " << $1 << " does not exist in table") << std::endl;

										if( f == nullptr ) 
											std::cout << FRED("ERROR: ID " << $3 << " does not exist in table") << std::endl;
										
										// check for correct parameters to function
										if( !checkParameters(f, argumentVector) ) 
											std::cout << FRED("ERROR: Incorrect parameters in function call") << std::endl;

										argumentVector.clear();

										// Compare ID type and function return type
										if (e->dtype != f->returntype) {
											printf(FRED("SEMANTIC ERROR::Type mismatch\n"));
										}
										
										/* ---- AST ACTIONS by PARSER ---- */
										AST* id_1 = (AST*) malloc(sizeof(AST));
										AST* fun = (AST*) malloc(sizeof(AST));
										id_1 = New_Tree($1, NULL, NULL);
										fun = New_Tree($3, $5, NULL);
										$$ = New_Tree($2, id_1, fun);
									}
	| ID OSB MathExpr CSB EQ ID OPAR ArgList CPAR 	{
														/* --- SEMANTIC CHECKS --- */
														// check if first ID exists in table or parameters
														Entry* e = checkExistance(current, $1, parameterVector);
														Entry* f = checkExistance(current, $6, parameterVector);
														
														if( e == nullptr || e->dtype != "int" ) 
															std::cout << FRED("ERROR: ID " << $1 << " does not exist in table or has a type mismatch in assignment statement") << std::endl;

														if( f == nullptr || f->returntype != "int" ) 
															std::cout << FRED("ERROR: ID " << $6 << " does not exist in tablee or has a type mismatch in assignment statement") << std::endl;
														
														// check for correct parameters to function
														if( !checkParameters(f, argumentVector) ) 
															std::cout << FRED("ERROR: Incorrect parameters in function call") << std::endl;

														argumentVector.clear();

														// Compare ID type and function return type
														if (e->dtype != f->returntype) {
															printf(FRED("SEMANTIC ERROR::Type mismatch\n"));
														}
														
														/* ---- AST ACTIONS by PARSER ---- */
														AST* id_1 = New_Tree($1, NULL, NULL);
														AST* arr = New_Tree("ARRAY", id_1, $3);
														AST* fun = New_Tree($6, $8, NULL);
														$$ = New_Tree($5, arr, fun);
													}
	| ID EQ ID OSB NUMBER CSB 	{
									/* --- SEMANTIC CHECKS --- */
									checkIntType(current, $1);
									checkIntType(current, $3);
									
									/* ---- AST ACTIONS by PARSER ---- */
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
											/* --- SEMANTIC CHECKS --- */
											checkIntType(current, $1);

											/* ---- AST ACTIONS by PARSER ---- */
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
									/* ---- AST ACTIONS by PARSER ---- */
									$$ = New_Tree("ARG", $1, $3);
								}
;

MathExpr:	MathExpr PLUS MathExpr 	{
									/* ---- IR Code Generator ---- */
									std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
									std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
									std::string result_reg = IrGen::getRegister();
									IrGen::printIrCodeCommand("add", result_reg + ",", arg1 + ",", arg2);

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										std::cout << "\nRECOGNIZED RULE: Math Expression\nTOKENS: " << $1->nodeType << " " << 
								   		 $2<< " " << $3->nodeType << std::endl;

									/* ---- AST ACTIONS by PARSER ---- */
									AST* op = New_Tree($2, $1, $3, result_reg);
									$$ = op;
								}
| MathExpr MINUS MathExpr 	{
									/* ---- IR Code Generator ---- */
									std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
									std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
									std::string result_reg = IrGen::getRegister();
									IrGen::printIrCodeCommand("sub", result_reg + ",", arg1 + ",", arg2);

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										std::cout << "\nRECOGNIZED RULE: Math Expression\nTOKENS: " << $1->nodeType << " " << 
								   		 $2<< " " << $3->nodeType << std::endl;

									/* ---- AST ACTIONS by PARSER ---- */
									AST* op = New_Tree($2, $1, $3, result_reg);
									$$ = op;
								}
| MathExpr DIV MathExpr 	{
									/* ---- IR Code Generator ---- */
									std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
									std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
									std::string result_reg = IrGen::getRegister();
									IrGen::printIrCodeCommand("div", result_reg + ",", arg1 + ",", arg2);

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										std::cout << "\nRECOGNIZED RULE: Math Expression\nTOKENS: " << $1->nodeType << " " << 
								   		 $2 << " " << $3->nodeType << std::endl;

									/* ---- AST ACTIONS by PARSER ---- */
									AST* op = New_Tree($2, $1, $3, result_reg);
									$$ = op;
								}
| MathExpr MULT MathExpr 	{
									/* ---- IR Code Generator ---- */
									std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
									std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
									std::string result_reg = IrGen::getRegister();
									IrGen::printIrCodeCommand("mult", result_reg + ",", arg1 + ",", arg2);

									/* ---- SEMANTIC ACTIONS by PARSER ---- */
									if(debug)
										std::cout << "\nRECOGNIZED RULE: Math Expression\nTOKENS: " << $1->nodeType << " " << 
								   		 $2 << " " << $3->nodeType << std::endl;

									/* ---- AST ACTIONS by PARSER ---- */
									AST* op = New_Tree($2, $1, $3, result_reg);
									$$ = op;
								}
|	OPAR MathExpr CPAR	{
							/* ---- AST ACTIONS by PARSER ---- */
							$$ = $2;
						}
| NUMBER	{
				/* ---- Code Generation ---- */
				std::string reg = IrGen::getRegister();
				std::string num = std::to_string($1);
				IrGen::printIrCodeCommand("li", num, reg, "");

				/* --- SYMBOL TABLE CHECKS  --- */
				Entry* e = new Entry("Int", std::to_string($1));
				argumentVector.push_back(e);


				/* ---- AST ACTIONS by PARSER ---- */
				if(debug)
					printf("\n RECOGNIZED RULE: NUMBER\nTOKENS: %d\n", $1);
				char num_s[100];
				sprintf(num_s, "%d", $1);
				$$ = New_Tree(num_s, NULL, NULL, reg);
			}
| ID	{
			/* --- SEMANTIC CHECKS --- */
			Entry* e = current->searchEntry($1);
			if (e == nullptr && !parameterVector.empty()) { // TODO: check for parameters too!!!
				for (int i = 0; i < parameterVector.size(); i++) {
					if ($1 == parameterVector.at(i)->name) {
						std::cout<<"FOUND IT"<<std::endl;
						e = parameterVector.at(i);
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

			/* ---- AST ACTIONS by PARSER ---- */
			if(debug)
				printf("\nRECOGNIZED RULE: ID\n");
			$$ = New_Tree($1, NULL, NULL);
}
| ID OSB MathExpr CSB 	{
							/* ---- AST ACTIONS by PARSER ---- */
							AST* id = (AST*) malloc(sizeof(AST));
							id = New_Tree($1, NULL, NULL);
							$$ = New_Tree("ARRAY", id, $3);
						}
;

RelExpr: MathExpr GTE MathExpr	{
										/* ---- GENERATE IR CODE ---- */
										std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
										std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
										if(is_while)
											curr_label = ".L" + std::to_string(lable_counter+1);
										else
											curr_label = ".L" + std::to_string(lable_counter);
										//lable_counter++;
										IrGen::printIrCodeCommand("blt", arg1 + ",", arg2 + ",", curr_label);

										/* ---- AST ACTIONS by PARSER ---- */
										if(debug)
											printf("\nRECOGNIZED RULE: Relational Expression\n");
										$$ = New_Tree($2, $1, $3);
									}
| MathExpr LTE MathExpr	{
							/* ---- GENERATE IR CODE ---- */
							std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
							std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
							if(is_while)
								curr_label = ".L" + std::to_string(lable_counter+1);
							else
								curr_label = ".L" + std::to_string(lable_counter);
							//lable_counter++;
							IrGen::printIrCodeCommand("bgt", arg1 + ",", arg2 + ",", curr_label);


							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| MathExpr GT MathExpr	{
							/* ---- GENERATE IR CODE ---- */
							std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
							std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
							if(is_while)
								curr_label = ".L" + std::to_string(lable_counter+1);
							else
								curr_label = ".L" + std::to_string(lable_counter);
							//lable_counter++;
							IrGen::printIrCodeCommand("blt", arg1 + ",", arg2 + ",", curr_label);
							IrGen::printIrCodeCommand("beq", arg1 + ",", arg2 + ",", curr_label);

							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");

							$$ = New_Tree($2, $1, $3);
						}
| MathExpr LT MathExpr	{
							/* ---- GENERATE IR CODE ---- */
							std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
							std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
							if(is_while)
								curr_label = ".L" + std::to_string(lable_counter+1);
							else
								curr_label = ".L" + std::to_string(lable_counter);
							//lable_counter++;
							IrGen::printIrCodeCommand("bgt", arg1 + ",", arg2 + ",", curr_label);
							IrGen::printIrCodeCommand("beq", arg1 + ",", arg2 + ",", curr_label);


							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| MathExpr EQEQ MathExpr	{
							/* ---- GENERATE IR CODE ---- */
							std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
							std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
							if(is_while)
								curr_label = ".L" + std::to_string(lable_counter+1);
							else
								curr_label = ".L" + std::to_string(lable_counter);
							//lable_counter++;
							IrGen::printIrCodeCommand("beq", arg1 + ",", arg2 + ",", curr_label);


							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| MathExpr NOTEQ MathExpr	{
							/* ---- GENERATE IR CODE ---- */
							std::string arg1 = $1->reg != "" ? $1->reg : IrGen::loadGlobal($1->nodeType);
							std::string arg2 = $3->reg != "" ? $3->reg : IrGen::loadGlobal($3->nodeType);
							if(is_while)
								curr_label = ".L" + std::to_string(lable_counter+1);
							else
								curr_label = ".L" + std::to_string(lable_counter);
							//lable_counter++;
							IrGen::printIrCodeCommand("bneq", arg1 + ",", arg2 + ",", curr_label);

							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| RelExpr AND RelExpr 	{
							/* ---- GENERATE IR CODE ---- */

							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}	
| RelExpr OR RelExpr	{
							/* ---- GENERATE IR CODE ---- */


							/* ---- AST ACTIONS by PARSER ---- */
							if(debug)
								printf("\nRECOGNIZED RULE: Relational Expression\n");
							$$ = New_Tree($2, $1, $3);
						}
| MathExpr { $$ = $1; }
;

Tail: OPAR ParamDeclList CPAR {IrGen::scope_counter++; } Block 	{
																	/* ---- AST ACTIONS by PARSER ---- */
																	if(debug)
																		printf("\nRECOGNIZE RULE: Function Decl\n");
																	$$ = New_Tree("params_holder", $2, $5);

																	IrGen::scope_counter--;
																}
;

Block: OCB {
				current = new Table(current);
				tempCounter++;
			} 
			VarDeclList StmtList {
									if (current->parent != nullptr) {
										//current->printEntries();
										current = current->parent;
										//std::cout << "MOVING UP A LEVEL" << std::endl;
									}
								} 
			CCB 	{
						/* ---- AST ACTIONS by PARSER ---- */
						if(debug)
							printf("\nRECOGNIZED RULE: Block\n");
						AST* block = (AST*)malloc(sizeof(AST));
						block = New_Tree("block", $3, $4);
						$$ = block;
						IrGen::clearScopedRegisters();
					}
;

ParamDeclList: ParamDecl COMMA ParamDeclList 	{
													/* ---- AST ACTIONS by PARSER ---- */
													insert_node_left($1, $3);
													$$ = $1;
												}
	| ParamDecl	{ $$ = $1; }
;

ParamDecl: /* empty */ { $$ = NULL; }
	| TYPE ID  	{
					/* --- SYMBOL TABLE ACTIONS by PARSER --- */
					Entry* e = new Entry($2, $1);
					parameterVector.push_back(e);
					//current->insertEntry(e);

					/* ---- AST ACTIONS by PARSER ---- */
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

							/* ---- AST ACTIONS by PARSER ---- */
							AST* id = New_Tree($2, NULL, NULL);
							AST* type = New_Tree($1, NULL, NULL);
							$$ = New_Tree("array", type, id);
						}	
%%

int main(int argc, char**argv) {
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n##### COMPILER STARTED #####\n\n");

	std::cout << "##### Opening IR Code File #####\n";
	IrGen::openFile();
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();

	std::cout << "#### Closing IR Code File ####\n";
	IrGen::closeFile();
	
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
