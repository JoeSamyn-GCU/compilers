#include <string>

#include "semanticUtilities.h"
#include "colors.h"
#include <vector>
/*
    from ISac:
    checkType()
    compareTypes()
    returnsResultingType

    1.  [x] No identifier is declared twice in the same scope (inside symbol table)
    2.  [x] No identifier is used before it is declared (checkExistance)
        * check $n by searching the symbol table
    3.  [x] The int literal in an array declaration must be greater than 0 (If statement in parser)
    4.  [x] The number and types of arguments in a function call must be the same as the number and types in the function definition
        * take stack of parameter functions of the function call and put them in a vector
        * use a semantic helper function to check the number and type of the arguments matches the number and type of the function definition
    5.  [x] If a function call is used as an expression, the function must return a result
        * semantic helper function that checks for return type in table
    6.  [] A return statement must not have a return value unless it appears in the body of a function that is declared to return a value.
        * semantic helper function that checks for return type in table
    7.  [] The expression in a return statement must have the same type as the declared result type of the enclosing function definition
        * semantic helper function that checks for return type in table (modify to check return type)
    8.  [] For all locations of the form id[expr]:
        9.  [] id must be an array variable
            * check in expr when array is called to see if id is within bounds (table check inside helper function)
            * semantic helper function to retrieve nelements from entry in table
        10. [] the type of expr must be int
            * under Expr in parser.y:
            * check $ns and compare them to symbol tables to make sure they are ints
    11. []  The expr in if and while statements must have type boolean
        * semantic helper function that checks for return type in table (modify to check return type)
    12. []  The operands of arithmetic Op and RelOp must have type int or float
        * check $ns to see if they are int or float inside arithmetic expressions
        * semantic helper function that checks for return type in table (modify to check return type)
    13. [x]  The operands of eq op must have the same type (compareTypes)
        * TEST!!!
    14. [x]  The operands of cond op and the operand of logical not (!) must have type boolean. (compareTypes)
        * TEST!!!
    15. []  All break and continue statements must be contained within the body of a loop
        * check table to see if in loop scope (from parser)
        * NOTE: Requires loop scope to be listed inside loop scope table
 */



// bool compareIdTypes(Table table, char* a, char* b) {
//     Entry* A = table.searchEntry(a);
//     Entry* B = table.searchEntry(b);
    
//     return strcmp((A->dtype).c_str(), (B->dtype).c_str());
// }

// bool checkExistance(Table table, char* id) {
//     if( table.searchEntry(id) != nullptr )
//         return true;
//     else
//         std::cout << FRED("**ERROR::ENTRY DOES NOT EXISTS:: Cannot find ") << FRED(std::to_string(id)) << FRED("in symbol table") << std::endl;
//         return false;
// }

Entry* checkExistance(Table* table, char* entryID, std::vector<Entry*> parameterVector) {
    Entry* e = table->searchEntry(entryID);
    if (e == nullptr && !parameterVector.empty()) {
        for (int i = 0; i < parameterVector.size(); i++) {
            if (entryID == parameterVector.at(i)->name) {
                e = parameterVector.at(i);
                return e;
            }
        }
    }
    return nullptr;
}

bool checkParameters(Entry* function, std::vector<Entry*> &arguments) {
    if (function == nullptr) {
        return false;
    }
    if (function->params.size() != arguments.size()) {
        printf(FRED("SEMANTIC ERROR::Function called with incorrect number of elements\n"));
        std::cout << "VECTORS WRONG SIZE. " << function->params.size() << " != " << arguments.size() << std::endl;
        return false;
    }
    else {
        // check if parameters correct
        for (int i = 0; i < function->params.size(); i++) {
            std::cout<<"parameter: "<< function->params.at(i)->dtype<<" argument: "<<arguments.at(function->params.size()-i-1)->dtype << std::endl;
            if (function->params.at(i)->dtype != arguments.at(function->params.size() - i-1)->dtype) {
                //std::cout<<"THEY ARE DIFFERENT"<<std::endl;
                printf(FRED("SEMANTIC ERROR::Function called with incorrect elements\n"));
                return false;
            }
        }
        return true;
    }
}