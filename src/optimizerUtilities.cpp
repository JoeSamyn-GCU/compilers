#include "optimizerUtilities.h"
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <vector>

void redundantFunctionElimination(Table* root) {
    std::vector<std::string> deadLabels;
    findUnusedEntries(root, deadLabels);
    if (deadLabels.size() == 0) {
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
    
    while(std::getline(ifile, fileLine)) {
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
        if (foundLabel == false && !fileLine.empty()) {
            ofile<<fileLine<<std::endl;
        }
        else if (fileLine.find("jr $ra") != std::string::npos) {
            foundLabel = false;
        }
    }
    ifile.close();
    ofile.close();

    // Can comment out this line for testing
    rename("bin/temp.asm","bin/ircode.asm");
}

void findUnusedEntries(Table* root, std::vector<std::string> &deadLabels) {
    // iterate through child tables
    if (root->entries.size() > 0) {
        for(const std::pair<std::string, Entry*>& n : root->entries) {
            if (n.second->returntype != "" && n.second->uses < 1) {
                deadLabels.push_back(n.first);
            }
        }
    }
    for (int i = 0; i < root->tables.size(); i++) {
        findUnusedEntries(root->tables.at(i), deadLabels);
    }
}
