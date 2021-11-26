#ifndef ENTRY_H
#define ENTRY_H

#include <string>
#include <vector>

/**
 * Struct data structure used to hold an entry in the scoped symbol table
 */
class Entry {
    /* Properties */
    public:
        /**
         * Constructor to initialize object properties
         */
        // Entry(std::string name, std::string dtype){
        //     this->name = name;
        //     this->dtype = dtype;
        // }

        Entry(std::string name = "", 
            std::string dtype = "", 
            std::string scope = "", 
            int nelements = 0,
            int nparams = 0,         
            std::vector<Entry*> params = {},
            std::string returntype = "",
            int uses = 0,
            int nline = 0,
            int nchar = 0,
            std::string stype = "",
            std::string lexeme = "",
            std::string value = "") 
        {
            this->name = name;
            this->dtype = dtype;
            this->nelements = nelements;
            this->nparams = nparams;
            this->params = params;
            this->returntype = returntype;
            this->uses = uses;
            this->nline = nline;
            this->nchar = nchar;
            this->stype = stype;
            this->lexeme = lexeme;
            this->value = value;
        }
        /**
         * Name of the entry
         */
        std::string name;

        /**
         * Data type of the entry
         */
        std::string dtype;

        /**
         * Current string representation of the scope of the entry
         */
        std::string scope;

        /**
         * Number of elementents in the entry (if array)
         */
        int nelements;

        /**
         * Number of parameters in the entry (if function)
         */
        int nparams;

        /**
         * Array of parameters. (order matters)
         */
        std::vector<Entry*> params;

        /**
         * Mode of the parameter (pass by value or pass by reference)
         */
        std::vector<std::string> pmode;

        /**
         * Return type of the function (functions only)
         */
        std::string returntype;

        /**
         * How many times entry is used (data for optimization phase of compiler)
         */
        int uses;

        /**
         * Line number in code entry is found
         */
        int nline;

        /**
         * Character number of starting character in the code file for the entry
         */
        int nchar;

        /**
         *symbol type the type of symbol associated to token by lexer, i.e. number, keyword, operator, variable, etc.
        */
        std::string stype;

        /**
         * The actual character sequence read by the lexer
         */
        std::string lexeme;

        /**
         * Value assigned to the variable (if applicable, can be used for performance)
         */
        std::string value;

    /* Methods */
    public:
        // TODO: Add print method that prints all properties in an entry object
        /**
         * Prints all not null properties in an entry object
         * 
         * @param e Entry object to verbosly print
         * @return 
         */
        void print_entry(Entry* e); 
};


#endif