#include "symbolTable.h"
#include "colors.h"


Table::Table() {
    this->parent = nullptr;
}

Table::Table(Table* parent) {
    this->parent = parent;
    parent->tables.push_back(this);
}

Table::~Table() {

}

int Table::insertEntry(Entry* e) {
    
    // Check if entry exists, it does print error and return.
    // TODO: throw an invalid argument exception and catch it in the parser to signify DUPLICATE SYMBOL semantic error
    if(this->searchEntry(const_cast<char*>(e->name.data())) != nullptr) {
        std::cout << FRED("**ERROR::ENTRY ALREADY EXISTS:: Cannot enter duplicate entries into symbol table:: Entry Name: ") << e->name << std::endl;
        return 1;
    }

    // TODO: Add logic to run search in parent scopes first before inserting

    // If not found insert into entries table
    entries[e->name] = e;
    return 0;
}

Entry* Table::deleteEntry(char* name) {
    // If entry hash table is empty just return
    if( entries.size() == 0 ) {
        std::cout << FYEL("**WARNING::Entries hash table is empty. There is nothing to delete") << std::endl;
        return nullptr;
    }
    Entry* e;
    // Search the map for "name", if not found, display a warning and return nullptr
    try {
        e = entries.at(name);
    }
    // Expected if key not in range
    catch (const std::out_of_range){
        std::cout << FYEL("**WARNING::Entries is not in the table. There is nothing to delete") << std::endl;
        return nullptr;
    }
    // Since it has been found, erase and return value
    entries.erase(name);
    return e;
}

Entry* Table::searchEntry(char* name) {
    // Recursively call parent. If not null, return result
    if (parent != nullptr) {
        Entry* parentResult = parent->searchEntry(name);
        if (parentResult != nullptr) {
            std::cout << FYEL("**WARNING::Entry in parent table") << std::endl;
            return parentResult;
        }
    }
    
    // If entry hash table is empty, return nullptr
    if( entries.size() == 0 ) {
        std::cout << FYEL("**WARNING::Entries hash table is empty. There is nothing to search") << std::endl;
        return nullptr;
    }
    
    // Search the map for "name", if not found, display a warning and return nullptr
    Entry* e;
    try {
        e = entries.at(name);
    }
    // Expected if key not in range
    catch (const std::out_of_range){
        std::cout << FYEL("**WARNING::Entry is not in the table.") << std::endl;
        return nullptr;
    }
    return e;
}

// TODO: Enable verbose printing
void Table::printEntries(bool verbose) {
    //if (parent != nullptr) {
    //    parent->printEntries();
    //}
    // If entry hash table is empty just return
    if( entries.size() == 0 ) {
        std::cout << FYEL("**WARNING::Entries hash table is empty. There is nothing to print") << std::endl;
        return;
    }
    std::cout << "\nTABLE ENTRIES" << std::endl << "--------------------------------------" << std::endl;
    std::cout << "KEY\t\t" << "VALUE" << std::endl << "--------------------------------------" << std::endl;

    // Else iterate through unordered_map and print all key value pairs
    // TODO: FORMAT for verbose printing and simplified
    for(const std::pair<std::string, Entry*>& n : entries){
        std::cout << n.first << "\t" << n.second->dtype << "\t" << n.second->scope << "\t" << n.second->nelements << "\t" << n.second->nparams << std::endl; 
        if (n.second->params.size() > 0) {
            std::cout << n.second->params.size() << std::endl;
        }
    }
}

// TODO: Enable verbose printing
void Table::printTables(bool verbose) {
    this->printEntries();
    for (int i = 0; i < tables.size(); i++) {
        tables.at(i)->printTables();
    }
}
