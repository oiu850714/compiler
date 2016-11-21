%{
#include <stdio.h>
#include <stdlib.h>

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

/* keyword */
%token WHILE DO IF ELSE TRUE FALSE FOR
%token INT PRINT CONST READ BOOLEAN BOOL
%token VOID FLOAT DOUBLE STRING CONTINUE BREAK RETURN
/* while do if else true false for int print const read boolean
 bool void float double string continue break return */

/* identifier */
%token ID

/* constant literal */
%token INT_CONST FLOAT_CONST SCIEN_CONST STR_CONST

%%

program : decl_and_def_list
	;

decl_and_def_list	: decl_and_def_list declaration_list
			| decl_and_def_list definition_list
			;

declaration_list : declaration_list const_decl
                 | declaration_list var_decl
                 | declaration_list funct_decl
				 ;

var_decl : type identifier SEMICOLON
         ;

type : INT
     ; 

identifier : ID
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

