#include "irgen.h"

/* Begin IrGen Implementation */
std::ofstream IrGen::ofile;

std::queue<Qe*> IrGen::qe_stack;

int IrGen::r_counter;

void IrGen::openFile(){
    r_counter = 0;
    ofile.open("bin/ircode.txt");
}

void IrGen::closeFile(){
    ofile.close();
}

std::string IrGen::printIrCode(){

    if(!qe_stack.empty()){

        std::string lreg = "";

        
        // Loop through stack and print all IR code in reverse order
        while(!qe_stack.empty()){
            
            Qe* qe = qe_stack.front();
            qe_stack.pop();

            ofile << qe->result << " = " << qe->arg1 << " " << qe->op << " " << qe->arg2 << std::endl;

            // save last register
            lreg = qe->result;

            // free memory used by Quadruples entry
            delete qe;
        }

        return lreg;
    }

    return "";

}

void IrGen::insertQe(std::string op, std::string arg1, std::string arg2){

    /*
    * If this is the first operation, the stack is empty and therefor a result register 
    * does not currently exist
    */
   if(qe_stack.empty()){
       r_counter++;

       std::string reg = "r" + std::to_string(r_counter);
       Qe* qe = new Qe(op, arg1, arg2, reg);
       qe_stack.push(qe);
   }
   /*
   * Else the stack is not empty, we need to use the result register of the top 
   * node on the stack
   */
   else {
        r_counter++;
        
        if(isOp(arg1)){
            Qe* top = qe_stack.front();
            qe_stack.pop();
            Qe* next = qe_stack.front();

            std::string reg = "r" + std::to_string(r_counter);
            Qe* qe = new Qe(op, next->result, top->result, reg);
            qe_stack.push(top);
            qe_stack.push(qe);
        }
        else{
            std::string reg = "r" + std::to_string(r_counter);
            Qe* top = qe_stack.front();
            Qe* qe = new Qe(op, arg1, top->result, reg);
            qe_stack.push(qe);
        }
        
   }    

}

bool IrGen::isOp(std::string val){
    
    return val == "+" 
    || val == "-"
    || val == "/"
    || val == "*";
}

/* End IrGen Implementation */

/* Begin Qe Implementation */
Qe::Qe(std::string op, std::string arg1, std::string arg2){
    this->op = op;
    this->arg1 = arg1;
    this->arg2 = arg2;
}

Qe::Qe(std::string op, std::string arg1, std::string arg2, std::string result){
    this->op = op;
    this->arg1 = arg1;
    this->arg2 = arg2;
    this->result = result;
}