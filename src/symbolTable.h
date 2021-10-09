#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iterator>
#include <algorithm>


typedef struct Entry {
    char* name;
    char* dtype;
    char* scope; 
    int nelements;
    int nparams;
    char* ptype;
    char* pmode;
    char returntype;
    int uses;
    int nline;
    int nchar;
    char* stype;
    char* lexeme;
    char* value;
} Entry;


class Table {

    public:
        /**
         * Vector used to hold entries in the current scope table
         */
        std::vector<Entry*> entries; // TODO: Switch to hash table (unordered_map in C++)

        /**
         * Vector used to hold all child scope tables
         */
        std::vector<Table*> tables; // TODO: Switch to hash table (unordered_map in C++)

        /**
         * Pointer to parent scope table
         */
        Table* parent;

        /**
         * Default constructor to initialize parent pointer
         * 
         * @param
         * @return
         */
        Table();

        /**
         * Constructor used to initialize a table with a parent node
         * 
         * @param parent the parent of the new table object being created
         * @return
         */
        Table(Table* parent);

        /**
         * Insert new entry into the symbol table in the current tables scope
         * 
         * @param e Entry object to insert into the table
         * @return
         */
        void insertEntry(Entry e);

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
         * @param
         * @return
         */
        void printEntries();
};

#endif