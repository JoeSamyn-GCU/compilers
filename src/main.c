/**
 * Main function that can be used for testing AST and symbol table code
 * In order to test your code, just write a console application using the
 * methods that were built out in the header/c files. Debugging can be used
 * when running this main function. Just ensure that you have navigated to 
 * the src folder in the console and run the make command
 */
#include <stdio.h>
#include "symbolTable.h"
#include "AST.h"

int main() {
    Entry test;
    test.name = (char*)"x";
    test.type = (char*)"int";
    Table* table = new Table();
    table->insertEntry((char*)"test");
    table->printEntries();
    printf("Hello Compiler People!\nAdd Test Code Here..\n");
    table->deleteEntry((char*)"test");
    table->printEntries();
}