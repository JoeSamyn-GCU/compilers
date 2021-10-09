#ifndef ENTRY_H
#define ENTRY_H

#include <string>
#include <vector>

/**
 * Struct data structure used to hold an entry in the scoped symbol table
 */
class Entry {
    public:
        /**
         * Constructor to initialize object properties
         */
        Entry(std::string name, std::string dtype){
            this->name = name;
            this->dtype = dtype;
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
         * Array of parameter types. (order matters)
         */
        std::vector<std::string> ptype;

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