#ifndef SEMANTICUTILITIES_H
#define SEMANTICUTILITIES_H

#include "symbolTable.h"
#include <string>


/*
    from ISac:
    checkType()
    compareTypes()
    returnsResultingType

    1. No identifier is used before it is declared
    2. The int literal in an array declaration must be greater than 0
    3. The number and types of arguments in a function call must be the same as the number and types in the function definition
    4. If a function call is used as an expression, the function must return a result
    5. A return statement must not have a return value unless it appears in the body of a function that is declared to return a value.
    6. The expression in a return statement must have the same type as the declared result type of the enclosing function definition
    7. For all locations of the form id[expr]:
    8. id must be an array variable
    9. the type of expr must be int
    10. The expr in if and while statements must have type boolean
    11. The operands of arithmetic Op and RelOp must have type int or float
    12. The operands of eq op must have the same type
    13. The operands of cond op and the operand of logical not (!) must have type boolean.
    14. All return statements must return the same type as the function type
 */


bool compareTypes(string a, string b) {
    a = searchEntry(a);
    b = searchEntry(b);
    
    return std::strcmp(a.dtype, b.dtype);
}

bool checkExistance(string id) {
    if( searchEntry(id) != nullptr )
        return true;
    else
        return false;
}

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

