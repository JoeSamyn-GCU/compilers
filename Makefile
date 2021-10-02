# --- NOTES ---
# $? = dependent files 

# Tell make which compiler to use
CC = gcc
# Which flags to pass to the compilation command
CFLAGS = -G
# Add header file dependencies
DEBS = AST.h 
# Define Include Directories
INCLUDES = -I src
# C source files
SRC = lex.yy.c parser.tab.c
# Set executable output name and directory
BIN = bin/parser

all: parser-run
	@echo Building and Running Parser files



# Generate bison C and H files
parser.tab.c: parser.y
	@echo Generating parser C and H files...
	bison -t -v -d $?

# Generate lexer C files 
lex.yy.c: lexer.l
	@echo Generating lexer C files...
	flex $?

# Build parser code
parser: $(SRC)
	@echo Building parser executable...
	$(CC) $(INCLUDES) -o $(BIN) $?

# Execute Parser code
parser-run: parser
	@echo Executing parser using testProg.cmm
	bin/parser testProg.cmm

# Remove all binaries, flex, and bison generated files
clean:
	rm -f parser lexer parser.tab.c lex.yy.c parser.tab.h parser.output
	ls -l
