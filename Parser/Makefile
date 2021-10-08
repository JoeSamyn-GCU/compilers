# ---- Makefile for generating and building Parser code ---- #

all: parser

# Generate bison C and H files
parser:
	@echo Generating parser C and H files...
	bison -t -v -d parser.y
	@mv parser.tab.c parser.tab.h ../build

