# ---- Makefile used to build main test function ---- #

CC = g++
CFLAGS = -g
SRC = AST.cpp main.cpp symbolTable.cpp irgen.cpp
BIN = bin/main.exe

all: main

main:
	$(CC) $(CFLAGS) -o $(BIN) $(SRC)
	bin/main.exe


clean:
	@rm -rf bin
	@mkdir bin