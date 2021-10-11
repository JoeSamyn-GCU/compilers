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

int main() {

    Entry* e1 = new Entry("Test Entry", "int");
    Entry* e2 = new Entry("Test Entry 2", "char");

    Table* table = new Table();
    Table* childTable = new Table(table);
    table->printEntries();
    childTable->insertEntry(e1);
    table->insertEntry(e2);
    Entry* e3c = childTable->searchEntry("Test Entry");
    std::cout<<"(c) Searched and found "<<e3c->name<<std::endl;
    table->printEntries();
    Entry *e3 = table->searchEntry("Test Entry");
    if (e3 != nullptr) {
        std::cout<<"Searched and found "<<e3->name<<std::endl;
    }

    table->deleteEntry("Test Entry");
    table->deleteEntry("Test Entry");
    
    table->searchEntry("Test Entry");
    
    table->printEntries();

    delete e1;
    delete e2;
    delete table;
    delete childTable;

    return 0;
}