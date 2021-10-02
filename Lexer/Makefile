# ---- Makefile to generate lexer files ---- # 

# Generate Lexer file using flex
all: gen
	@echo Generating lexer C files...
	@mv lex.yy.c ../build/lex.yy.c

gen: lexer.l
	flex $?
