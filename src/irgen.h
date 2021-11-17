#ifndef IRGEN_H
#define IRGEN_H

#include <stack>
#include <deque>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>

#include "colors.h"
#include <vector>

/**
 * @brief Class used to hold data for Quadruples table
 * 
 * @see { @link https://www.tutorialspoint.com/compiler_design/compiler_design_intermediate_code_generations.htm }
 */
class Qe {
    /* Public Properties */
    public:
        std::string op;
        std::string arg1;
        std::string arg2;
        std::string result;
    
    /* Public Methods */
    public:
        Qe(std::string op, std::string arg1, std::string arg2, std::string result);
        Qe(std::string op, std::string arg1, std::string arg2);
};

/**
 * @brief Class to hold IR code generation utilities
 */
class IrGen {

    /* Public Static Methods */
    public:
        /**
         * @brief Open file to write IR code to
         * 
         */
        void openFile();

        /**
         * @brief Close file that was used for outputing IR Code
         * 
         */
        void closeFile();

        /**
         * @brief Print the IR code of the values in the stack
         * 
         * @return last register used in 3-address code
         */
        std::string printIrCode();

        /**
         * @brief Insert a quadruples entry into the quadruples stack
         * 
         * @param op operator for the 3-address code
         * @param arg2 first argument in 3-address code
         * @param arg3 second argument in 3-address code. Can be empty and uses empty string as default value
         * @return register the result was assigned to
         */
        std::string printIrCode(std::string op, std::string arg2, std::string arg3 = "");
        
        /**
         * @brief Insert a quadruples entry into the quadruples stack
         * 
         * @param command ARM command to execute
         * @param arg1 first argument in 3-address code
         * @param arg2 second argument in 3-address code. Can be empty and uses empty string as default value
         * @param label label to jump to depending on command result
         */
        void printIrCodeCommand(std::string command, std::string arg1, std::string arg2, std::string label);

        /**
         * @brief print the label for a new section in IR code
         * 
         * @param label the lable string to print 
         */
        void printLabel(std::string label);

        /**
         * @brief Insert a quadruples entry into the quadruples stack
         * 
         * @param op operator for the 3-address code
         * @param arg1 first argument in 3-address code
         * @param arg2 second argument in 3-address code. Can be empty and uses empty string as default value
         */
        std::string insertQe(std::string op, std::string arg1, std::string arg2 = "");

        /**
         * @brief Checks if value is operator or not
         * 
         * @param value string to compare to ops
         * @return true value is an operator
         * @return false
         */
        bool isOp(std::string value);

        /**
         * @brief Checks if value is operator or not
         * 
         * @param value string to compare to ops
         * @return true value is an operator
         * @return false
         */
        bool isRelOp(std::string value);
        
        /**
         * @brief get the next available register
         * 
         * @param var the variable being searched for
         * @return open register string
         */
        std::string getRegister(std::string var = "");

        /**
         * @brief add variable name and register number to dictionary to keep track of mapped variables
         * 
         * @param var variable to add into map
         * @param reg register to map to variable
         * @return
         */
        void mapVarToReg(std::string var, std::string reg, bool update = false);

        /**
         * @brief get the register that was mapped to the variabled
         * 
         * @param var variable to get register for
         * @return register mapped to the variable. Empty string if none found
         */
        std::string getMappedRegister(std::string var);

        /**
         * @brief clear all variables that were mapped to registers in this scope
         * 
         */
        void clearMappedVarsInScope();

        /**
         * @brief clear the registers that were used in this scope
         * 
         * TODO: This will need to be improved. Crude approach to register management
         */
        void clearScopedRegisters();

        /**
         * @brief generate assembly code to load global variable into a register
         * 
         * @param var variable to load into register
         * @return register the global variable was loaded into
         */
        std::string loadGlobal(std::string var);

        /**
         * @brief store value in register into a global variable
         * 
         * @param reg register containing the value to store
         * @param id id of the global variable 
         * @return
         */
        void storeGlobal(std::string reg, std::string id);

        /**
         * @brief print MIPS syscall instruction
         * 
         * @return
         */
        void syscall();

        /**
         * @brief print instruction to jump to label
         * 
         * @param label label to jump to in mips
         */
        void printJump(std::string label);

    /* Public Static Variables */
    public:
        /**
         * @brief output file stream object
         * 
         */
        std::ofstream ofile;

        /**
         * @brief stack used to hold Quadruples entries when printing IR code
         * 
         */
        std::deque<Qe*> qe_deque;

        /**
         * Table used to maintain all IR code needed in a function. 
         * table is cleared when a scope is 
         */
        std::vector<Qe*> ir_table;

        /**
         * @brief string array used to hold values at various registers
         */
        bool registers[15];

        /**
         * @brief temp integer used to keep track of general register number
         * 
         */
        int r_counter;

        /**
         * @brief integer used to keep track of current scope depth
         * 
         */
        int scope_counter;

        /**
         * @brief Hashmap used to keep track of mappings between registers and variables
         *
         */
        std::unordered_map<std::string, std::string> var_reg;

};

#endif