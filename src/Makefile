# ---- Makefile used to build main test function ---- #

CC = g++
CFLAGS = -g
SRC = AST.c main.c
BIN = bin/main.exe

all: run

main:
	@echo
	@echo #########################################
	@echo ## 			Running Tests            ##
	@echo #########################################
	$(CC) $(CFLAGS) -o $(BIN) $(SRC)

run: main
	bin/main.exe
