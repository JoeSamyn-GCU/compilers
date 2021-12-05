#ifndef OPTIMIZERUTILITIES_H
#define OPTIMIZERUTILITIES_H

#include "AST.h"
#include "symbolTable.h"
#include <string>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op);


/** 
* @brief remove redundant code from MIPS 
* @param root root of symbol table
*/
void redundantFunctionElimination(Table* root);

void findUnusedEntries(Table* root, std::vector<std::string> &redundantEntries);


/** 
 * @brief removes redundant expressions
*/
// void removeRedundant(File ircode);  // do stuff with fstream
// rough idea of what may be needed. Follow Artzi's method for subexpression removal

#endif