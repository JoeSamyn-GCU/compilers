#include "optimizerUtilities.h"
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <vector>

// std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op){
//     std::string reduced;

// 	if (!mathExpr1->right->isNumber) { // left side will always be a number, right side will be a new expression
//         reduced = returnExpr(mathExpr1->right->left, mathExpr1->right->right, mathExpr1->right->nodeType);
//         reduced = std::to_string(std::stoi(reduced) + std::stoi(mathExpr2->nodeType));
//         return reduced; // added to stop errors from printing to console, not used;
//     } else if (mathExpr1->isNumber && mathExpr2->isNumber) {
//         if (op == "+") {
//             reduced = std::to_string(std::stoi(mathExpr1->nodeType) + std::stoi(mathExpr2->nodeType));
//         } else if (op == "-") {
//             reduced = std::to_string(std::stoi(mathExpr1->nodeType) - std::stoi(mathExpr2->nodeType));
//         } else if (op == "*") {
//             reduced = std::to_string(std::stoi(mathExpr1->nodeType) * std::stoi(mathExpr2->nodeType));
//         } else if (op == "/") {
//             reduced = std::to_string(std::stoi(mathExpr1->nodeType) / std::stoi(mathExpr2->nodeType));
//         }
//         return reduced;
//     } else {
//         return "";
//     }
// }

void redundantFunctionElimination(Table* root) {
    std::vector<std::string> deadLabels;
    std::vector<std::string> unusedVariables;
    findUnusedEntries(root, deadLabels, unusedVariables);
    //std::cout<<"redundantEntries:"<<redundantEntries.size()<<std::endl;
    if (deadLabels.size() == 0) {
        //std::cout<<"No redundant entries found"<<std::endl;
        return;
    }

    std::string label;
    std::string fileLine;
    std::ifstream ifile;
    std::ofstream ofile;
    bool foundLabel = false;
    ifile.open("bin/ircode.asm");
    ofile.open("bin/temp.asm");
    //! TESTING
    int lineNum = 0;

    while(std::getline(ifile, fileLine)) {
        //! TESTING
        lineNum++;
        std::cout<<"Line Number: "<<lineNum<<std::endl;

        if (fileLine.find(":") != std::string::npos && deadLabels.size() > 0) { // file line is a label
            // Find label if it exists in deadLabels
            for (int i = 0; i < deadLabels.size(); i++) {
                if (fileLine == (deadLabels.at(i) + ":")) { // found label
                    std::cout<<"FOUND LABEL"<<std::endl;
                    deadLabels.erase(deadLabels.begin()+i); // remove label from list
                    foundLabel = true;
                    break;
                }
            }
        }
        if (foundLabel == false) {
            // check for unused variables
            //! Currently not implemented
            if (unusedVariables.size() > 0) {
                for (int i = 0; i < unusedVariables.size(); i++) {
                    if (fileLine.find(unusedVariables.at(i))) {
                        std::cout<<"FOUND UNUSED VARIABLE"<<std::endl;
                        unusedVariables.erase(unusedVariables.begin()+i);
                        break;
                    }
                }
            }
            if (!fileLine.empty()) { // remove extra space
                ofile<<fileLine<<std::endl;
            }
        }
        else if (fileLine.find("jr $ra") != std::string::npos) {
            foundLabel = false;
        }
    }
    ifile.close();
    ofile.close();
    // Can comment out this line for testing
    //rename("bin/temp.asm","bin/ircode.asm");
}

void findUnusedEntries(Table* root, std::vector<std::string> &deadLabels, std::vector<std::string> &unusedVariables) {
    //todo 
    // 1. implement traversal to find functions that do not have 'uses'
    // 2. add entry name list of labels
    // 3. open and remove redundant code from the ircode.asm file
    // 3a. remove code from start of label to start of next label. This will remove redundant code
    // Note include exceptions for main method
    
    // iterate through child tables
    if (root->entries.size() > 0) {
        for(const std::pair<std::string, Entry*>& n : root->entries) {
            if (n.second->returntype != "" && n.second->uses < 1) {
                deadLabels.push_back(n.first);
            }
            else if (n.second->uses < 1) {
                unusedVariables.push_back(n.first);
            }
        }
    }
    for (int i = 0; i < root->tables.size(); i++) {
        findUnusedEntries(root->tables.at(i), deadLabels, unusedVariables);
    }
}
