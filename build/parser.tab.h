/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TYPE = 258,
     ID = 259,
     SEMICOLON = 260,
     EQ = 261,
     NUMBER = 262,
     PLUS = 263,
     WRITE = 264,
     WRITELN = 265,
     MINUS = 266,
     MULT = 267,
     DIV = 268,
     OSB = 269,
     CSB = 270,
     OCB = 271,
     CCB = 272,
     OPAR = 273,
     CPAR = 274,
     READ = 275,
     RETURN = 276,
     COMMA = 277,
     GTE = 278,
     LTE = 279,
     GT = 280,
     LT = 281,
     EQEQ = 282,
     NOTEQ = 283,
     WHILE = 284
   };
#endif
/* Tokens.  */
#define TYPE 258
#define ID 259
#define SEMICOLON 260
#define EQ 261
#define NUMBER 262
#define PLUS 263
#define WRITE 264
#define WRITELN 265
#define MINUS 266
#define MULT 267
#define DIV 268
#define OSB 269
#define CSB 270
#define OCB 271
#define CCB 272
#define OPAR 273
#define CPAR 274
#define READ 275
#define RETURN 276
#define COMMA 277
#define GTE 278
#define LTE 279
#define GT 280
#define LT 281
#define EQEQ 282
#define NOTEQ 283
#define WHILE 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 27 "parser.y"
{
	int number;
	char character;
	char* string;
	struct AST* ast;
}
/* Line 1529 of yacc.c.  */
#line 114 "parser.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

