#include "optimizerUtilities.h"
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <vector>

std::string returnExpr(AST* mathExpr1, AST* mathExpr2, std::string op){
    std::string reduced;

	if (!mathExpr1->right->isNumber) { // left side will always be a number, right side will be a new expression
        reduced = returnExpr(mathExpr1->right->left, mathExpr1->right->right, mathExpr1->right->nodeType);
        reduced = std::to_string(std::stoi(reduced) + std::stoi(mathExpr2->nodeType));
        return reduced; // added to stop errors from printing to console, not used;
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

void redundantFunctionElimination(Table* root) {
    std::vector<std::string> redundantEntries;
    findUnusedEntries(root, redundantEntries);
    std::cout<<"redundantEntries:"<<redundantEntries.size()<<std::endl;
    if (redundantEntries.size() == 0) {
        std::cout<<"No redundant entries found"<<std::endl;
        return;
    }

    std::string label;
    std::string fileLine;
    std::ifstream ifile;
    std::ofstream ofile;
    bool foundLabel = false;
    ifile.open("bin/ircode.asm");
    ofile.open("bin/temp.asm");
    while (!redundantEntries.empty()) {
        label = redundantEntries.back();
        label = label + ":";
        redundantEntries.pop_back();
        while (std::getline(ifile, fileLine)) {
            if (fileLine == label) {
                std::cout<<"FOUND LABEL";
                foundLabel = true;
            }
            else if (foundLabel) {
                // check to see if the next label is listed -> Stop removing lines and print as normal
                if (fileLine.find(":") != std::string::npos) {
                    ofile<<fileLine<<std::endl;
                    foundLabel = false;
                }
            }
            else {
                ofile<<fileLine<<std::endl;
            }
        }
    }
    ifile.close();
    ofile.close();
    // Can comment out this line for testing
    //rename("bin/temp.asm","bin/ircode.asm");
}

void findUnusedEntries(Table* root, std::vector<std::string> &redundantEntries) {
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
                redundantEntries.push_back(n.first);
            }
        }
    }
    for (int i = 0; i < root->tables.size(); i++) {
        findUnusedEntries(root->tables.at(i), redundantEntries);
    }
}
