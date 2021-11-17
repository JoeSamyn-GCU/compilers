/**
 * Main function that can be used for testing AST and symbol table code
 * In order to test your code, just write a console application using the
 * methods that were built out in the header/c files. Debugging can be used
 * when running this main function. Just ensure that you have navigated to 
 * the src folder in the console and run the make command
 */
#include <stdio.h>
#include "entry.h"
#include "symbolTable.h"
#include "colors.h"
#include "irgen.h"
#include <string>
// Global 

// main 
int main() {

    IrGen* gen = new IrGen();

    std::string i = gen->getMappedRegister("i");
    gen->mapVarToReg("i", "$t0");
    i = gen->getMappedRegister("i");

    return 0;
}
