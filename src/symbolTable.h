#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iterator>
#include <algorithm>
struct Entry {
    char* name;
    char* type;
};


class Table {
    public:
        std::vector<char*> entries; //replace with Entry struct
        std::vector<class Table> tables;
        class Table* parent;

        Table() {
            this->parent = NULL;
        }
        Table(Table* parent) {
            this->parent = parent;
        }
        // entries methods
        void insertEntry(char* e) {
            entries.push_back(e);
            //printf("inserted");
        }
        void deleteEntry(char* name) {
            std::vector<char*>::iterator it; // iterator, can be combined with line below
            it = std::find(entries.begin(), entries.end(), name); // wrong data types
            entries.erase(it);
        }
        void printEntries() {
            if (entries.size() == 0) {
                printf("No Entries\n");
            }
            else {
                for (int i = 0; i < entries.size(); i++) {
                    printf("%s\n",entries.at(i));
                }
            }
        }
        // Table methods (This one may be unneccessary)
        void addTable() {
            Table child = new Table(this);
            tables.push_back(child);
        }
};

struct SymbolTable {
    class Table* root;
};


//struct List insert(/* whatever arguments we end up using*/) {}

//struct List delete(/* whatever arguments we end up using*/) {}

//struct List select(/* whatever arguments we end up using*/) {}

#endif