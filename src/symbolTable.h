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
        std::vector<struct Entry> entries; //replace with Entry struct
        std::vector<class Table> tables;
        class Table* parent;

        Table() {
            this->parent = NULL;
        }

        Table(Table* parent) {
            this->parent = parent;
            parent->tables.push_back(this);
        }

        // entries methods
        void insertEntry(Entry e) {
            entries.push_back(e);
            //printf("inserted");
        }

        void deleteEntry(char* name) {
            auto searchEntry = [](const Entry & temp) {
                return temp.name;
            };
            std::vector<struct Entry>::iterator it;
            it = std::find_if(entries.begin(), entries.end(), searchEntry);
            entries.erase(it);
        }

        struct Entry searchEntry(char* name) {
            for (int i = 0; i < entries.size(); i++) {
                if (entries.at(i).name == name) {
                    return entries.at(i);
                }
            }
            
            Entry null; // Not great. It works for now
            return null;
        }
        
        void printEntries() {
            if (entries.size() == 0) {
                printf("No Entries\n");
            } 
            else {
                for (int i = 0; i < entries.size(); i++) {
                    printf("%s\n",entries.at(i).name);
                }
            }
        }
};

struct SymbolTable {
    class Table* root;
};


//struct List insert(/* whatever arguments we end up using*/) {}

//struct List delete(/* whatever arguments we end up using*/) {}

//struct List select(/* whatever arguments we end up using*/) {}

#endif