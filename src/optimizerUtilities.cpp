#include "optimizerUtilities.h"
#include <string>
#include <stdio.h>
#include <stdlib.h>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op){
    std::string reduced;

	if (mathExpr1->isNumber && mathExpr2->isNumber) {
        if (op == "+") {
            reduced = std::to_string(std::stoi(mathExpr1->nodeType) + std::stoi(mathExpr2->nodeType));
        } else if (op == "-") {
            reduced = std::to_string(std::stoi(mathExpr1->nodeType) - std::stoi(mathExpr2->nodeType));
        } else if (op == "*") {
            reduced = std::to_string(std::stoi(mathExpr1->nodeType) * std::stoi(mathExpr2->nodeType));
        } else if (op == "/") {
            reduced = std::to_string(std::stoi(mathExpr1->nodeType) / std::stoi(mathExpr2->nodeType));
        }
        return reduced;
    } else if (!mathExpr1->left->isNumber) {
        reduced = returnExpr(mathExpr1->left->left, mathExpr1->left->right, mathExpr1->left->nodeType);
        reduced = std::to_string(std::stoi(reduced) + std::stoi(mathExpr2->nodeType));
    }
}

void expressionElimination(Table* root) {
    root. 
}