%option noyywrap

%{
#include <stdio.h>
#include <string.h>

#define YY_DECL int yylex()
#include "parser.tab.h"

int words = 0;
int chars = 1;
int lines = 1;

%}

letter      [a-zA-Z]
digit       [0-9]
ID          {letter}({letter}|{digit})*
delim       [ \t\n]
NUMBER      {digit}+(\.{digit}+)?(E[+\-]?(digit)+)?
ws          {delim}+

%%
"/*"    				{
							int c;
							while((c = input()) != 0) {
								if(c == '*') {
									if((c = input()) == '/')
										break;
									else
										unput(c);
								}
							}
						}
						
"int"	{
			words++; chars += strlen(yytext);
			printf("%s : TYPE\n", yytext);
			yylval.string = strdup(yytext); 
			return TYPE;
		}

"write"	{
			words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return WRITE;
		}

{ID}	{
			words++; chars += strlen(yytext);
			printf("%s : IDENTIFIER\n",yytext);
			yylval.string = strdup(yytext); 
			return ID;
		}
			
{NUMBER}	{
				words++; chars += strlen(yytext);
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
			printf("%s : EQ\n", yytext);
			yylval.string = strdup(yytext); 
			return EQ;
		}
"+"		{
			chars++;
			printf("%s : PLUS\n", yytext);
			yylval.string = strdup(yytext);
			return PLUS;
		}
"-"		{
			chars++;
			printf("%s : MINUS\n", yytext);
			yylval.string = strdup(yytext);
			return MINUS;
		}
"*"		{
			chars++;
			printf("%s : MULT\n", yytext);
			yylval.string = strdup(yytext);
			return MULT;
		}
"/"		{
			chars++;
			printf("%s : DIV\n", yytext);
			yylval.string = strdup(yytext);
			return DIV;
		}
"["		{
			chars++;
			printf("%s : OSB\n", yytext);
			yylval.string = strdup(yytext);
			return OSB;
		}
"]"		{
			chars++;
			printf("%s : CSB\n", yytext);
			yylval.string = strdup(yytext);
			return CSB;
		}
		
[\n]	{lines++; chars=0;}
[ \t]	{chars++;}
.		{chars++;
         printf("%s : Unrecognized symbol at line %d char %d\n", yytext,lines,chars);
		}
		

%%