#include "optimizerUtilities.h"
#include <string>
#include <stdio.h>
#include <stdlib.h>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op){
    std::string reduced;

	if (!mathExpr1->right->isNumber) { // left side will always be a number, right side will be a new expression
        reduced = returnExpr(mathExpr1->right->left, mathExpr1->right->right, mathExpr1->right->nodeType);
        reduced = std::to_string(std::stoi(reduced) + std::stoi(mathExpr2->nodeType));
    } else if (mathExpr1->isNumber && mathExpr2->isNumber) {
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
    } else {
        return "";
    }
}

// void redundantFunctionElimination(Table* root) {
//     //todo 
//     // 1. implement traversal to find functions that do not have 'uses'
//     // 2. add entry name list of labels
//     // 3. open and remove redundant code from the ircode.asm file
//     // 3a. remove code from start of label to start of next label. This will remove redundant code

//     std::vector<std::string> labels;
    
//     //Inside traversal code or for loop
//     if (e->uses > 0) {
//         labels.push_back(e->name);
//     }
//     //end for loop

//     IrGen.openFile();
//     // somehow traverse file
//     // delete entries between two points, 
//     IrGen.closeFile();
// }