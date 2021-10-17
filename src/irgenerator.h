#ifndef IRGENERATOR_H
#define IRGENERATOR_H

#include <iostream>
#include <fstream>


std::ofstream outfile;


void openIrCodeFile(){
    outfile.open("bin/ircode.txt");
}

void closeIrCodeFile(){
    outfile.close();
}

#endif