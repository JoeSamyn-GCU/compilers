#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <vector>

class Table {
    public:
        vector<class Listnode> entries;
        vector<class Table> tables;
        class Table* parent;
};

struct SymbolTable {
    struct Table* root;
};


struct List insert(/* whatever arguments we end up using*/) {}

struct List delete(/* whatever arguments we end up using*/) {}

struct List select(/* whatever arguments we end up using*/) {}

#endif