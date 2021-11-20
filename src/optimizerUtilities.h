#ifndef OPTIMIZERUTILITIES_H
#define OPTIMIZERUTILITIES_H

#include "AST.h"
#include <string>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op);

#endif