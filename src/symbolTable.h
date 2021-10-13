#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <iostream>
#include <stdlib.h>
#include <unordered_map>
#include <vector>
#include <string>
#include <stdexcept>

#include "entry.h"

/**
 * Scope table object used to hold all entries within a specific scope
 */
class Table {

    public:
    // TODO: add table name
    
        /**
         * Vector used to hold entries in the current scope table
         */
        std::unordered_map<std::string, Entry*> entries;

        /**
         * Vector used to hold all child scope tables
         */
        std::vector<Table*> tables;

        /**
         * Pointer to parent scope table
         */
        Table* parent;

        /**
         * Default constructor to initialize parent pointer
         * 
         * @param
         */
        Table();

        /**
         * Constructor used to initialize a table with a parent node
         * 
         * @param parent the parent of the new table object being created
         */
        Table(Table* parent);

        /**
         * Deconstructor used to clean up all pointers used in the object
         * 
         * @param
         */
        ~Table();

        /**
         * Insert new entry into the symbol table in the current tables scope
         * 
         * @param e Entry object to insert into the table
         * @return
         */
        int insertEntry(Entry* e);

        /**
         * Delete entry from the symbol table in the current scope
         * 
         * @param name name of entry to delete
         * @return deleted entry
         */
        Entry* deleteEntry(char* name);

        /**
         * Search for an entry in the symbol table
         * 
         * @param name Name of the entry to search for
         * @return the first Entry that matches the search criteria
         */
        Entry* searchEntry(char* name);
        
        /**
         * Print all entries in the current Scope table
         * 
         * @param verbose if set to true, all properties in Entry object will be printed to console. 
         * If false then just entry name and datatype is printed to console
         * @return
         */
        void printEntries(bool versbose = false);
};

#endif