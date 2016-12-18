#include <string.h>
	enum basic_type 
	{
		INT_t,
		FLOAT_t,
		DOUBLE_t,
		STRING_t,
		BOOL_t		
	};

	struct whole_type
	{
		enum basic_type type;
		int dimemsions_of_type[256]; 
	};

	enum kind
	{
		function,
		parameter,
		variable,
		constant
	};

	//above is variaous columns about symbol table entries.

	struct symbol_table_entry
	{
		char var_name[257];
		enum kind kind_t;
		//not implement level in this struct, cause symbol table already has it.
		struct  whole_type type;
		//a lot of struct to represent columns
		struct symbol_table_entry *next;
	};


	struct symbol_table_level
	{
		//represent symbol table's level
		int global_or_local_flag;
		//global = 0, local = 1; 
		int level;
	};

	struct symbol_table
	{
		//struct about symbol table, and use linked list to link all created symbol tables
		struct symbol_table_level level;
		struct symbol_table_entry *entries;
		struct symbol_table *next;
	};


//above is all abunt symbol table implementation


enum operator_t
{
	PLUS_t,
	SUB_AND_MINUS_t,
	MULTI_t,
	DIV_t,
	MOD_t,
};

struct expression_ATTR
{
	enum basic_type type;
};

//exp 應該只要存 exp的 value type就好了?不用存operator
//應該還是要存，畢竟exp不單單只有type這個資訊


//above is all new defined types of [non]terminal's attribute


union const_literal_val
{
	int const_int_value;
	double const_float_double_value;
	char const_string_value[257];
	int const_bool_value;
};

struct const_literal_ATTR
{
	union const_literal_val val;
	enum basic_type type;
};



