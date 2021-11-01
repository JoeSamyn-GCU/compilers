%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include <iostream>
#include "colors.h"


#define YY_DECL int yylex()
#include "parser.tab.h"

int words = 0;
int chars = 1;
int lines = 1;
bool debug_print = false;

%}

letter      [a-zA-Z]
digit       [0-9]
ID          {letter}({letter}|{digit})*
delim       [ \t\n]
NUMBER      {digit}+(\.{digit}+)?(E[+\-]?(digit)+)?
ws          {delim}+
str 		\"([^\\\"]|\\.)*\"

%%
"/*"    				{
							int c;
							while((c = yyinput()) != 0) {
								if(c == '*') {
									if((c = yyinput()) == '/')
										break;
									else
										unput(c);
								}
							}
						}
						
"int"|"char"|"float"|"void"	{
							words++; chars += strlen(yytext);
							if(debug_print)
								printf("%s : TYPE\n", yytext);
							yylval.string = strdup(yytext); 
							return TYPE;
						}

"write"	{
			words++; chars += strlen(yytext);
			if(debug_print)
				printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return WRITE;
		}

"read"	{
			words++; chars += strlen(yytext);
			if(debug_print)
				printf("%s : KEYWORD READ\n", yytext);
			yylval.string = strdup(yytext); 
			return READ;
		}

"writeln" 	{
				words++; chars += strlen(yytext);
				if(debug_print)
					printf("%s : KEYWORD WRITELN\n", yytext);
				yylval.string = strdup(yytext); 
				return WRITELN;
			}
"return" 	{
				words++; chars += strlen(yytext);
				if(debug_print)
					printf("%s : KEYWORD RETURN\n", yytext);
				yylval.string = strdup(yytext); 
				return RETURN;
			}
"while" 	{
				words++; chars += strlen(yytext);
				if(debug_print)
					printf("%s : KEYWORD WHILE\n", yytext);
				yylval.string = strdup(yytext); 
				return WHILE;
			}
"if" 		{
				words++;
				chars += strlen(yytext);
				if(debug_print)
					printf("%s : KEYWORD IF\n", yytext);
				yylval.string = strdup(yytext);
				return IF;
			}
"else" 		{
				words++;
				chars += strlen(yytext);
				if(debug_print)
					printf("%s : KEYWORD ELSE\n", yytext);
				yylval.string = strdup(yytext);
				return ELSE;
			}

{ID}	{
			words++; chars += strlen(yytext);
			if(debug_print)
				printf("%s : IDENTIFIER\n",yytext);
			yylval.string = strdup(yytext); 
			return ID;
		}
			
{NUMBER}	{
				words++; chars += strlen(yytext);
				if(debug_print)
					printf("%s : NUMBER\n",yytext);
				yylval.number = atoi(strdup(yytext)); 
				return NUMBER;
			}
			
";"		{
			chars++;
			yylval.string = strdup(yytext); 
			return SEMICOLON;
		}
		
"="		{
			chars++;
			if(debug_print)
				printf("%s : EQ\n", yytext);
			yylval.string = strdup(yytext); 
			return EQ;
		}
"+"		{
			chars++;
			if(debug_print)
				printf("%s : PLUS\n", yytext);
			yylval.string = strdup(yytext);
			return PLUS;
		}
"-"		{
			chars++;
			if(debug_print)
				printf("%s : MINUS\n", yytext);
			yylval.string = strdup(yytext);
			return MINUS;
		}
"*"		{
			chars++;
			if(debug_print)
				printf("%s : MULT\n", yytext);
			yylval.string = strdup(yytext);
			return MULT;
		}
"/"		{
			chars++;
			if(debug_print)
				printf("%s : DIV\n", yytext);
			yylval.string = strdup(yytext);
			return DIV;
		}
"["		{
			chars++;
			if(debug_print)
				printf("%s : OSB\n", yytext);
			yylval.string = strdup(yytext);
			return OSB;
		}
"]"		{
			chars++;
			if(debug_print)
				printf("%s : CSB\n", yytext);
			yylval.string = strdup(yytext);
			return CSB;
		}
"("		{
			chars++;
			if(debug_print)
				printf("%s : OPAR\n", yytext);
			yylval.string = strdup(yytext);
			return OPAR;
		}
")"		{
			chars++;
			if(debug_print)
				printf("%s : CPAR\n", yytext);
			yylval.string = strdup(yytext);
			return CPAR;
		}
"{"		{
			chars++;
			if(debug_print)
				printf("%s : OCB\n", yytext);
			yylval.string = strdup(yytext);
			return OCB;
		}
"}"		{
			chars++;
			if(debug_print)
				printf("%s : CCB\n", yytext);
			yylval.string = strdup(yytext);
			return CCB;
		}
","		{
			chars++;
			if(debug_print)
				printf("%s : COMMA\n", yytext);
			yylval.string = strdup(yytext);
			return COMMA;
		}
"<"		{
			chars++;
			if(debug_print)
				printf("%s : LT\n", yytext);
			yylval.string = strdup(yytext);
			return LT;
		}
">"		{
			chars++;
			if(debug_print)
				printf("%s : GT\n", yytext);
			yylval.string = strdup(yytext);
			return GT;
		}
">="		{
			chars += 2;
			if(debug_print)
				printf("%s : GTE\n", yytext);
			yylval.string = strdup(yytext);
			return GTE;
		}
"<="		{
			chars += 2;
			if(debug_print)
				printf("%s : LTE\n", yytext);
			yylval.string = strdup(yytext);
			return LTE;
		}
"=="	{
			chars += 2;
			if(debug_print)
				printf("%s : EQEQ\n", yytext);
			yylval.string = strdup(yytext);
			return EQEQ;
		}
"!="	{
			chars += 2;
			if(debug_print)
				printf("%s : NOTEQ\n", yytext);
			yylval.string = strdup(yytext);
			return NOTEQ;
		}
"&&"	{
			chars += 2;
			if(debug_print)
				printf("%s : AND\n", yytext);
			yylval.string = strdup(yytext);
			return AND;
		}
"||"	{
			chars += 2;
			if(debug_print)
				printf("%s : OR\n", yytext);
			yylval.string = strdup(yytext);
			return OR;
		}
{str}	{
				chars += strlen(yytext);
				if(debug_print)
					printf("%s : STRING\n", yytext);
				yylval.string = strdup(yytext);
				return STRING;
			}
		
[\n]	{lines++; chars=0;}
[\t]	{chars++;}
[\r]	{chars++;}
" "	 	{chars++;}
.		{	
			chars++;
			char c = *yytext;
			printf("%d\n", c);
			printf("\033[0;31m");
         	printf("ERROR::Unrecognized symbol at line %d char %d\n", lines,chars);
			printf("\033[0m");
		}
		

%%