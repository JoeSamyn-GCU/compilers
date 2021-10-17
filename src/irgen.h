#ifndef IRGEN_H
#define IRGEN_H

#include <stack>
#include <queue>
#include <fstream>
#include <iostream>
#include <string>

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
        static void openFile();

        /**
         * @brief Close file that was used for outputing IR Code
         * 
         */
        static void closeFile();

        /**
         * @brief Print the IR code of the values in the stack
         * 
         * @return last register used in 3-address code
         */
        static std::string printIrCode();
        
        /**
         * @brief Insert a quadruples entry into the quadruples stack
         * 
         * @param op operator for the 3-address code
         * @param arg1 first argument in 3-address code
         * @param arg2 second argument in 3-address code. Can be empty and uses empty string as default value
         */
        static void insertQe(std::string op, std::string arg1, std::string arg2 = "");

        /**
         * @brief Checks if value is operator or not
         * 
         * @param value string to compare to ops
         * @return true value is an operator
         * @return false
         */
        static bool isOp(std::string value);

    /* Public Static Variables */
    public:
        /**
         * @brief output file stream object
         * 
         */
        static std::ofstream ofile;

        /**
         * @brief stack used to hold Quadruples entries when printing IR code
         * 
         */
        static std::queue<Qe*> qe_stack;

        /**
         * @brief temp integer used to keep track of general register number
         * 
         */
        static int r_counter;


};

#endif