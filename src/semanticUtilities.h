#ifndef SEMANTICUTILITIES_H
#define SEMANTICUTILITIES_H

#include "symbolTable.h"
#include "colors.h"
#include <string>


bool compareIdTypes(Table table, char* a, char* b);

bool compareIdMathExpr(Table table, char* a, char* b);

// bool checkArgs(std::string a, std::string b) {
//     std::string arrayType = searchEntry(a).dtype;
//     std::stringstream ss(b);
//     std::string word;
//     bool typesMatch;

//     while (ss >> word) 
//         typesMatch == std::strcmp(arrayType, word);
    
//     return typesMatch;
// }

bool checkExistance(Table table, char* id);

#endif

//  ***********************************
//  *                                 *
//  *  ***    ***   ***   ****  ***   *
//  *  *  *  *   * *   *  *     *  *  *
//  *  ***   *   * * *    ****  *   * *
//  *  *  *  *   * *  *   *     *  *  *
//  *  ***    ***  *   *  ****  ***   *
//  *                                 *
//  ***********************************