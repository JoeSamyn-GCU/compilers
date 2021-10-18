# --- NOTES ---
# $? = dependent files 

# Tell make which compiler to use
CC = g++
# Which flags to pass to the compilation command
CFLAGS = -G
# Define Include Directories
INCLUDES = -I src
# C source files
SRC = build/lex.yy.c build/parser.tab.c src/AST.cpp
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
	$(CC) $(INCLUDES) -o $(BIN) $(SRC)
	@echo
	@echo
	@echo Executing parser using testProg.cmm...
	bin/gmm TestFiles/symbol_table_test.cmm

# Remove all binaries, flex, and bison generated files
clean:
	rm -rf build bin
	mkdir build bin
	ls -l
