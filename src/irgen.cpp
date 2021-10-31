#include "irgen.h"

/* 
In ARM we can use registers R0 - R10 for general purpose, except R7 which is reserved for System Calls
*/

/* Begin IrGen Implementation */
std::ofstream IrGen::ofile;
std::deque<Qe*> IrGen::qe_deque;
std::map<std::string, std::string> IrGen::var_reg;
bool IrGen::registers[15];
int IrGen::scope_counter = 0;
int IrGen::r_counter;

void IrGen::openFile(){
    r_counter = 0;
    ofile.open("bin/ircode.txt");
}

void IrGen::closeFile(){
    ofile.close();
}

std::string IrGen::printIrCode(){

    if(!qe_deque.empty()){

        std::string lreg = "";

        
        // Loop through stack and print all IR code in reverse order
        while(!qe_deque.empty()){
            
            Qe* qe = qe_deque.back();
            qe_deque.pop_back();

            if(!isRelOp(qe->op))
                ofile << qe->result << " = " << qe->arg1 << " " << qe->op << " " << qe->arg2 << std::endl;
            else
                ofile << qe->arg1 << " " << qe->op << " " << qe->arg2 << std::endl;

            // save last register
            lreg = qe->result;

            // free memory used by Quadruples entry
            delete qe;
        }

        return lreg;
    }

    return "";

}


std::string IrGen::insertQe(std::string op, std::string arg1, std::string arg2){

    std::string reg = "";
    /*
    * If this is the first operation, the stack is empty and therefor a result register 
    * does not currently exist
    */
   if(qe_deque.empty()){
       r_counter++;

       reg = "r" + std::to_string(r_counter);
       Qe* qe = new Qe(op, arg1, arg2, reg);
       qe_deque.push_back(qe);
   }
   /*
   * Else the stack is not empty, we need to use the result register of the top 
   * node on the stack
   */
   else {
        r_counter++;
        
        if(isOp(arg1)){
            Qe* top = qe_deque.front();
            qe_deque.pop_front();
            Qe* next = qe_deque.front();

            reg = "r" + std::to_string(r_counter);
            Qe* qe = new Qe(op, next->result, top->result, reg);
            qe_deque.push_front(top);
            qe_deque.push_back(qe);
        }
        else{
            std::string reg = "r" + std::to_string(r_counter);
            Qe* top = qe_deque.front();
            Qe* qe = new Qe(op, arg1, top->result, reg);
            qe_deque.push_back(qe);
        }
   }   

   return reg; 

}

std::string IrGen::printIrCode(std::string op, std::string arg1, std::string arg2){
    std::string result_register = "";

    // find result register 
    result_register = getRegister("");
    if(result_register == "-1"){
        std::cout << FRED("ERROR::Register overflow. Ran out of CPU registers\n");
        return "";
    }

    ofile << result_register << " = " << arg1 << " " << op << " " << arg2 << std::endl;

    return result_register;
}

void IrGen::printIrCodeCommand(std::string command, std::string arg1, std::string arg2, std::string label){

     ofile << command << " " << arg1 << " " << arg2 << " " << label << std::endl;
}

void IrGen::printLabel(std::string label){
    ofile << std::endl << label << std::endl;
}

std::string IrGen::getRegister(std::string var){

    // If var is not empty, we are looking for matching variable
    if(var != ""){
        for(int i = 0; i < 10; i++){
            
            if(!registers[i]){
                registers[i] = true;
                return "$t" + std::to_string(i);
            }
        }
    }

    // We are not looking for a matching variable or did not find one
    for(int i = 0; i < 15; i++){
        if(!registers[i]&& i != 7){
            registers[i] = true;
            return "$t" + std::to_string(i);
        }
    }

    return "-1";
}

bool IrGen::isOp(std::string val){
    
    return val == "+" 
    || val == "-"
    || val == "/"
    || val == "*";
}

bool IrGen::isRelOp(std::string val){
    return val == ">"
    || val == "<"
    || val == "="
    || val == "<="
    || val == ">="
    || val == "IF";
}

void IrGen::mapVarToReg(std::string var, std::string reg){
    if(var_reg.find(var) == var_reg.end()){
        var_reg[var] = reg;
    }
    else{
        var = var + std::to_string(scope_counter);
        var_reg[var] = reg;
    }
}

std::string IrGen::getMappedRegister(std::string var){
    if(var_reg.find(var) == var_reg.end()){
        return "";
    }

    return var_reg[var];
}

std::string IrGen::loadGlobal(std::string var){
    std::string reg = IrGen::getRegister();
    std::string gp = "($gp)";
    IrGen::printIrCodeCommand("lw", var.append(gp) + ",", reg, "");
    return reg;
}

void IrGen::clearScopedRegisters(){
    for(int i = 0; i < 15; i++){
        registers[i] = false;
    }
}

void IrGen::storeGlobal(std::string reg, std::string id){
    std::string gp = "($gp)";
    IrGen::printIrCodeCommand("sw", reg + ",", id.append(gp), "");
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