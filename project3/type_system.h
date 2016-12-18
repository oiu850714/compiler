#include <stdlib.h>
#include <string.h>

typedef enum 
{
	INT_t,
	FLOAT_t,
	DOUBLE_t,
	STR_t,
	BOOL_t
} basic_type;

typedef struct 
{
	int dimensions;
	//dimensions store how many dimensions in total
	int dimension_list[256];
	//dimension_list store each dimension's length, assuming not exceed 256 dimensions
} array_type;

typedef struct 
{
	basic_type basic;
	array_type array_dimension;
} whole_type;
// above is entry impementation for "type" column in symbol table

typedef enum
{
	function,
	parameter,
	variable,
	constant
} kind;
// above is entry implemenatation for "kind" column in symbol table

typedef union 
{
	int CONST_INT_val;
	float CONST_FLOAT_val;
	double CONST_DOUBLE_val;
	char CONST_STR_val[257];
} const_val;

typedef struct
{
	whole_type func_para_type[256];
	whole_type return_type;
} func_para_list;

typedef union
{
	const_val attr_const_val;
	func_para_list attr_function;

} attr;

typedef struct ENTRY
{
	char name_column[33];
	kind kind_column;
	whole_type type_column;
	attr attr_column;
	struct ENTRY *next;
} entry;
// entry consists of all columns of symbol table,
// but no level_column, which is in symbol table
// next ptr links all entries in symbol table

typedef struct SYMBOL_TABLE 
{
	entry *entry_list;
	int level;
	struct SYMBOL_TABLE *next;
} symbol_table;
// symbol table implementation

symbol_table *table_list_head = NULL;

void new_symbol_table();
void exit_scope();
void clear_entries();
void entry_add_entry(entry *e_ptr);
void entry_add_dimension(entry *e_ptr, int length);
// so we need all entry inforamation when add new id into symbol table

//use fucking shit global variable table_list in functions below

void new_symbol_table()
{
	symbol_table* tmp = (symbol_table*)malloc(sizeof(symbol_table));
	if(table_list_head == NULL)
	{
		table_list_head = tmp;
		table_list_head -> level = 0;
		table_list_head -> next = NULL;
	}
	else
	{
		tmp -> next = table_list_head;
		table_list_head = tmp;
		table_list_head -> level = tmp -> level + 1;
	}
	table_list_head -> entry_list = NULL;
}

void exit_scope()
{
	symbol_table *tmp = table_list_head -> next;
	clear_entries();
	free(table_list_head);
	table_list_head = tmp;
}

void clear_entries()
{
	while(table_list_head -> entry_list)
	{
		entry *tmp = table_list_head -> entry_list -> next;
		free(table_list_head -> entry_list);
		table_list_head -> entry_list = tmp;
	}
}


// above are functions about creating a complete entry.

void entry_add_dimension(entry *e_ptr, int length)
{
	e_ptr -> type_column.array_dimension.dimension_list
	[e_ptr -> type_column.array_dimension.dimensions++] = length;
	// notice about zero-start convention!!
}

void entry_add_type(entry *e_ptr, basic_type t)
{
	e_ptr -> type_column.basic = t;
}

void entry_add_id(entry *e_ptr, char* id)
{
	strncpy(e_ptr -> name_column, id, 32);
}

void entry_add_kind(entry *e_ptr, kind kind_t)
{
	e_ptr -> kind_column = kind_t;
}

int main(int argc, char const *argv[])
{
	/* code */
	return 0;
}