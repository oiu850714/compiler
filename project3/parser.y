%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "attr_type.h"
	//this include let %union shut up
	int yylex();
	int yyerror( char *msg );
	extern int linenum;             /* declared in lex.l */
	extern FILE *yyin;              /* declared by lex */
	extern char *yytext;            /* declared by lex */
	extern char buf[256];           /* declared in lex.l */



	enum  basic_type get_exp_type(enum  basic_type type1, enum  basic_type type2)
	{
		if(type1 == DOUBLE_t || type2 == DOUBLE_t)
			return DOUBLE_t;
		else if(type1 == FLOAT_t || type2 == FLOAT_t)
			return FLOAT_t;
		else
			return INT_t;
	}

	void initial_new_symbol_table(struct symbol_table *head)
	{

		struct symbol_table* tmp = 
				(struct symbol_table*)malloc(sizeof(struct symbol_table));
		tmp -> level.global_or_local_flag = 0;
		tmp -> entries = NULL;
		tmp -> next = head;
		if(head == NULL)
			head = tmp;
		else
			head -> next = tmp;
	}

	void clear_entries(struct symbol_table_entry *entries)
	{
		while(entries)
		{
			struct symbol_table_entry *tmp = entries -> next;
			free(entries);
			entries = tmp;
		}
	}

	void exit_scope(struct symbol_table *head)
	{
		struct symbol_table* tmp = head -> next;
		clear_entries(head->entries);
		free(head);
		head = tmp;
	}

	struct symbol_table *head = NULL;

	int check_declare(char *str, struct symbol_table *head)
	{
		symbol_table_entry *tmp = head->entries;
		while(tmp)
		{
			if(strcmp(str, tmp->var_name))
			{
				tmp = tmp->next;
			}
			else
			{
				printf("fuckyou error\n");
				return 1;
			}
		}
		return 0;
	}





%}



%union 
{ 

	int INT_CONST_attr; 
	double FLOAT_CONST_attr;
	double SCIEN_CONST_attr;
	//don't know how to handle scientific
	int TRUE_FALSE_attr;
	char ID_STR_CONST_attr[257];
	struct expression_ATTR expression_attr;
	struct const_literal_ATTR const_literal_attr;
}

/* delimiter */
	%token COMMA 
	%token SEMICOLON 
	/* , and ; */
	
	%token L_PARAN 
	%token R_PARAN 
	%token L_SQUARE 
	%token R_SQUARE 
	%token L_BRACE 
	%token R_BRACE 
	/* ( ) [ ] { } */

/* operator */
	%token PLUS 
	%token SUB_AND_MINUS 
	%token MULTI 
	%token DIV 
	%token MOD 
	/* + - * / % */
	
	%token ASSIGN 
	/* = */
	
	%token LESS 
	%token LESS_EQUAL 
	%token NOT_EQUAL 
	%token GREAT_EQUAL 
	%token GREAT 
	%token EQUAL 
	/* < <= != >= > == */
	
	%token LOGI_AND 
	%token LOGI_OR 
	%token LOGI_NOT 
	/* && || ! */

/* declare precedence */
	%left MULTI DIV MOD
	%left PLUS SUB_AND_MINUS
	%left LESS LESS_EQUAL NOT_EQUAL GREAT_EQUAL GREAT EQUAL
	%right LOGI_NOT
	%left LOGI_AND
	%left LOGI_OR

/* keyword */ 
	%token WHILE 
	%token DO 
	%token IF 
	%token ELSE 
	%token <TRUE_FALSE_attr> TRUE
	%token <TRUE_FALSE_attr> FALSE 
	%token FOR
	%token INT 
	%token PRINT 
	%token CONST 
	%token READ 
	%token BOOL
	%token VOID 
	%token FLOAT 
	%token DOUBLE 
	%token STRING 
	%token CONTINUE 
	%token BREAK 
	%token RETURN
	/* while do if else true false for int print const read boolean
	 bool void float double string continue break return */

/* identifier */
	%token <ID_STR_CONST_attr> ID

/* constant literal */
	%token <INT_CONST_attr> INT_CONST 
	%token <FLOAT_CONST_attr> FLOAT_CONST 
	%token <SCIEN_CONST_attr> SCIEN_CONST 
	%token <ID_STR_CONST_attr> STR_CONST


// above should define all tokens returned by lex, and their attribute type.

	%type <const_literal_attr> const_literal
	%type <expression_attr> expression

// above define all needed attribute types associated with some
// particular nonterminals.


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

//above insert constant ID to symbol table
//and const_literal may need some type conversion
// e.g. const int i = 1.23 //i = i
// e.g. const int = 'w' //well C- has no character www
// e.g. const int = "wwww" //

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

compound : L_BRACE enter_new_scope statements R_BRACE exit_scope

		;

enter_new_scope :
		{
			initial_new_symbol_table(head);
		}
	;

exit_scope :
		{
			exit_scope(head);
			printf("win!!!!!!!!!\n");
		}
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

expression : expression PLUS expression 
			{
				$$.type = get_exp_type ($1.type ,$3.type); 
			}
		|	 expression SUB_AND_MINUS expression 
			{
				$$.type = get_exp_type ($1.type ,$3.type); 
			}
		|	 expression MULTI expression 
			{
				$$.type = get_exp_type ($1.type ,$3.type); 
			}
		|	 expression DIV expression 
			{
				$$.type = get_exp_type ($1.type ,$3.type); 
			}
		|	 expression MOD expression
			{
				if($1.type != INT_t || $3.type != INT_t)
				{
					printf("fuck you!\n");
					exit(1);
				}
				$$.type = INT_t;
			}
		|	 SUB_AND_MINUS expression %prec MULTI
			{
				$$.type = $2.type;
			}

		|	 expression LESS expression
			{
				$$.type = BOOL_t;
			}
		|	 expression LESS_EQUAL expression
			{
				$$.type = BOOL_t;
			}

		|	 expression EQUAL expression
			{
				$$.type = BOOL_t;
			}

		|	 expression GREAT_EQUAL expression
			{
				$$.type = BOOL_t;
			}

		|	 expression GREAT expression
			{
				$$.type = BOOL_t;
			}

		|	 expression NOT_EQUAL expression
			{
				$$.type = BOOL_t;
			}

		|	 expression LOGI_AND expression
			{
				$$.type = BOOL_t;
			}

		|	 expression LOGI_OR expression
			{
				$$.type = BOOL_t;
			}

		|	 LOGI_NOT expression 
			{
				$$.type = BOOL_t;
			}

		|	 L_PARAN expression R_PARAN { $$ = $2; }

		|	 const_literal
			{
				$$.type = $1.type;
			}

		|	 func_invoke

		|	 var_ref

		// var_ref seems need a lot work
		;

const_literal :	INT_CONST 
				{
					$$.val.const_int_value = $1;
					$$.type = INT_t;
				}
		|	 	FLOAT_CONST 
				{
					$$.val.const_float_double_value = $1;
					$$.type = FLOAT_t;
				}
		|	 	SCIEN_CONST 
				{
					$$.val.const_float_double_value = $1;
					$$.type = FLOAT_t;
				}
		|	 	STR_CONST 
				{ 
					strncpy($$.val.const_string_value, $1, 256);
					$$.type = STRING_t;
				}
		|		TRUE 
				{
					$$.val.const_bool_value = $1;
					$$.type = BOOL_t;
				}
		|		FALSE 
				{
					$$.val.const_bool_value = $1;
					$$.type = BOOL_t;
				}
		;


type : INT

	| DOUBLE

	| FLOAT

	| STRING

	| BOOL

	| VOID

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
	
	initial_new_symbol_table(head);
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}

