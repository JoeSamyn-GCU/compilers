#ifndef OPTIMIZERUTILITIES_H
#define OPTIMIZERUTILITIES_H

#include "AST.h"
#include <string>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op);


/** 
* @brief remove redundant code from MIPS 
* @param root root of symbol table
*/
void redundantFunctionElimination(Table* root);

/** 
 * @brief removes redundant expressions
*/
void removeRedundant(File ircode); 
// rough idea of what may be needed. Follow Artzi's method for subexpression removal

#endif