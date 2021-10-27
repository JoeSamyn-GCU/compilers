# --- NOTES ---
# $? = dependent files 

# Tell make which compiler to use
CC = g++
# Which flags to pass to the compilation command
CFLAGS = -G
# C++ Standard
STD = -std=c++11
# Define Include Directories
INCLUDES = -I src
# C source files
SRC = build/lex.yy.c build/parser.tab.c src/AST.cpp src/irgen.cpp
# Set executable output name and directory
BIN = bin/gmm
# List subdirectories
SUBDIRS = Lexer Parser

all: run

# ---- Build individual folders ---- #

# Generate lexer C files 
lexer: 
	@cd Lexer ; make

parser:
	@cd Parser ; make


# Run program
run:
	@echo "###################################################"
	@echo "###   Building and Running C-- Compiler files   ###"
	@echo "###################################################"
	@echo 
	for i in $(SUBDIRS) ; do \
		( cd $$i ; make) ; \
	done
	@echo Building executable...
	$(CC) $(STD) $(INCLUDES) -o $(BIN) $(SRC)
	@echo
	@echo
	@echo Executing parser using testProg.cmm...
	bin/gmm TestFiles/testProg.cmm

# Remove all binaries, flex, and bison generated files
clean:
	rm -rf build bin
	mkdir build bin
	ls -l
