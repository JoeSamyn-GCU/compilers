#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>

struct List {
    /* Linked List implementation (or vectors or whatever we end up using) */
};

struct Table {
    struct List* entry;
    struct List* tables;
    struct Table* parent;
};

struct SymbolTable {
    struct Table* root;
};


struct List insert(/* whatever arguments we end up using*/) {}

struct List delete(/* whatever arguments we end up using*/) {}

struct List select(/* whatever arguments we end up using*/) {}

#endif