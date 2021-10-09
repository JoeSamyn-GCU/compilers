#include "symbolTable.h"
#include "colors.h"


Table::Table() {
    this->parent = nullptr;
}

Table::Table(Table* parent) {
    this->parent = parent;
}

Table::~Table(){

}

void Table::insertEntry(Entry* e) {
    
    // Check if entry exists, it does print error and return.
    // TODO: throw an invalid argument exception and catch it in the parser to signify DUPLICATE SYMBOL semantic error
    if(entries.find(e->name) != entries.end()){
        std::cout << FRED("**ERROR::ENTRY ALREADY EXISTS:: Cannot enter duplicate entries into symbol table:: Entry Name: ") << e->name << std::endl;
        return;
    }

    // TODO: Add logic to run search in parent scopes first before inserting

    // If not found insert into entries table
    entries[e->name] = e;
}

Entry* Table::deleteEntry(char* name) {
    return nullptr;
}

Entry* Table::searchEntry(char* name) {
    return nullptr;
}

// TODO: Enable verbose printing
void Table::printEntries(bool verbose) {

    // If entry hash table is empty just return
    if( entries.size() == 0 ){
        std::cout << FYEL("**WARNING::Entries hash table is empty. There is nothing to print") << std::endl;
        return;
    }

    std::cout << "KEY\t\t" << "VALUE" << std::endl << "--------------------------------------" << std::endl;

    // Else iterate through unordered_map and print all key value pairs
    for(const std::pair<std::string, Entry*>& n : entries){
        std::cout << n.first << "\t" << n.second->dtype << std::endl; 
    }

}