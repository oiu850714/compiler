%{
#include <stdio.h>
#include <stdlib.h>
#include "type_system.h"
int yylex();
int yyerror( char *msg );
extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}

/* delimiter */
%token COMMA SEMICOLON /* , and ; */
%token L_PARAN R_PARAN L_SQUARE R_SQUARE L_BRACE R_BRACE /* ( ) [ ] { } */

/* operator */
%token PLUS SUB_AND_MINUS MULTI DIV MOD /* + - * / % */
%token ASSIGN /* = */
%token LESS LESS_EQUAL NOT_EQUAL GREAT_EQUAL GREAT EQUAL /* < <= != >= > == */
%token LOGI_AND LOGI_OR LOGI_NOT /* && || ! */

%left MULTI DIV MOD
%left PLUS SUB_AND_MINUS
%left LESS LESS_EQUAL NOT_EQUAL GREAT_EQUAL GREAT EQUAL
%right LOGI_NOT
%left LOGI_AND
%left LOGI_OR

/* keyword */
%token WHILE DO IF ELSE TRUE FALSE FOR
%token INT PRINT CONST READ BOOL
%token VOID FLOAT DOUBLE STRING CONTINUE BREAK RETURN
/* while do if else true false for int print const read boolean
 bool void float double string continue break return */

/* identifier */
%token ID

/* constant literal */
%token INT_CONST FLOAT_CONST SCIEN_CONST STR_CONST

%%

program : declaration_list decl_and_def_list
	| decl_and_def_list
	;

decl_and_def_list	: decl_and_def_list const_decl
					| decl_and_def_list var_decl
					| decl_and_def_list funct_decl
					| decl_and_def_list funct_definition
			        | funct_definition
					;




declaration_list : declaration_list const_decl
                 | declaration_list var_decl
                 | declaration_list funct_decl
                 | const_decl
                 | var_decl
                 | funct_decl
				 ;

funct_definition : type ID L_PARAN formal_arg_list R_PARAN compound
				;

const_decl : CONST type const_list SEMICOLON;
		;

const_list : const_list COMMA ID ASSIGN exact_one_minus
			| ID ASSIGN exact_one_minus
			;

exact_one_minus : const_literal
			| SUB_AND_MINUS const_literal

var_decl : type var_list SEMICOLON
         ;

var_list : var_list COMMA ID var_assignment
			| ID var_assignment
			| var_list COMMA ID array_decl array_assignment
			| ID array_decl array_assignment

array_decl : array_decl L_SQUARE INT_CONST R_SQUARE
		|	 L_SQUARE INT_CONST R_SQUARE
		;

var_assignment : ASSIGN expression
		|
		;

array_assignment : ASSIGN L_BRACE expressions R_BRACE
		|
		;

expressions : expression_fuck
		|
		;

expression_fuck : expression
		| expression_fuck COMMA expression
// trick for fucking COMMA

funct_decl : type ID L_PARAN formal_arg_list R_PARAN SEMICOLON
         ;


formal_arg_list : type_id
			|
			;

type_id : type_id COMMA type ID array_decl
			| type ID array_decl
			| type_id COMMA type ID
			| type ID
			;

statements : statements compound
		| statements simple
		| statements conditional
		| statements while
		| statements for
		| statements jump
		| statements func_invoke SEMICOLON
		// above let func_invoke be used both in statements and expressions
		| statements declaration_list
		|
		;

compound : L_BRACE statements R_BRACE
		;

simple : var_ref ASSIGN expression SEMICOLON
		| PRINT var_ref SEMICOLON
		| PRINT expression SEMICOLON
		| READ var_ref SEMICOLON
		;


var_ref : ID array_ref
		;

array_ref : array_ref L_SQUARE expression R_SQUARE
		|
		;
// array_ref 0+ []

conditional : IF L_PARAN expression R_PARAN compound
		| IF L_PARAN expression R_PARAN compound ELSE compound
		;

while : WHILE L_PARAN expression R_PARAN compound
		| DO compound WHILE L_PARAN expression R_PARAN SEMICOLON
		;

for : FOR L_PARAN for_exp SEMICOLON for_exp SEMICOLON for_exp R_PARAN compound
	| FOR L_PARAN for_exp SEMICOLON for_exp SEMICOLON  R_PARAN compound
	| FOR L_PARAN for_exp SEMICOLON SEMICOLON for_exp R_PARAN compound
	| FOR L_PARAN for_exp SEMICOLON SEMICOLON R_PARAN compound
	| FOR L_PARAN SEMICOLON for_exp SEMICOLON for_exp R_PARAN compound
	| FOR L_PARAN SEMICOLON for_exp SEMICOLON  R_PARAN compound
	| FOR L_PARAN SEMICOLON SEMICOLON for_exp R_PARAN compound
	| FOR L_PARAN SEMICOLON SEMICOLON R_PARAN compound
		;

for_exp : expression
		| var_ref ASSIGN expression
		;

jump : RETURN expression SEMICOLON
	|	BREAK SEMICOLON
	|	CONTINUE SEMICOLON
		;
		
func_invoke : ID L_PARAN expressions R_PARAN
		;

expression : expression PLUS expression /*{ $$ = $1 + $3; }*/
		|	 expression SUB_AND_MINUS expression /*{ $$ = $1 - $3; }*/
		|	 expression MULTI expression /*{ $$ = $1 * $3; }*/
		|	 expression DIV expression /*{ $$ = $1 / $3; }*/
		|	 expression MOD expression /*{ $$ = $1 % $3; }*/
		|	 SUB_AND_MINUS expression %prec MULTI /*{ $$ = -1 * $2; }*/
		|	 expression LESS expression
		|	 expression LESS_EQUAL expression
		|	 expression EQUAL expression
		|	 expression GREAT_EQUAL expression
		|	 expression GREAT expression
		|	 expression NOT_EQUAL expression
		|	 expression LOGI_AND expression
		|	 expression LOGI_OR expression
		|	 LOGI_NOT expression
		|	 L_PARAN expression R_PARAN
		|	 const_literal
		|	 func_invoke
		|	 var_ref
		;

const_literal :	INT_CONST
		|	 	FLOAT_CONST
		|	 	SCIEN_CONST
		|	 	STR_CONST
		|		TRUE
		|		FALSE
		;


type : INT| DOUBLE| FLOAT| STRING| BOOL| VOID
     ; 

%%

int yyerror( char *msg )
{
  fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
  fprintf( stderr, "|--------------------------------------------------------------------------\n" );
  exit(-1);
}

int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}

