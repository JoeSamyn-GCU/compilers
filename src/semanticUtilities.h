#ifndef SEMANTICUTILITIES_H
#define SEMANTICUTILITIES_H

#include "symbolTable.h"
#include <string>


/*
    from ISac:
    checkType()
    compareTypes()
    returnsResultingType

    1. No identifier is declared twice in the same scope
    2. No identifier is used before it is declared
    3. The int literal in an array declaration must be greater than 0
    4. The number and types of arguments in a function call must be the same as the number and types in the function definition
    5. If a function call is used as an expression, the function must return a result
    6. A return statement must not have a return value unless it appears in the body of a function that is declared to return a value.
    7. The expression in a return statement must have the same type as the declared result type of the enclosing function definition
    8. For all locations of the form id[expr]:
    9. id must be an array variable
    10. the type of expr must be int
    11. The expr in if and while statements must have type boolean
    12. The operands of arithmetic Op and RelOp must have type int or float
    13. The operands of eq op must have the same type
    14. The operands of cond op and the operand of logical not (!) must have type boolean.
    15. All break and continue statements must be contained within the body of a loop 
 */


int compareTypes(Entry a, Entry b) {
    return std::strcmp(a.dtype, b.dtype);
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

