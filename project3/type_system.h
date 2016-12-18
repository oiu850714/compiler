#include <stdlib.h>

typedef enum 
{
	INT_t,
	FLOAT_t,
	DOUBLE_t,
	BOOL_t
} basic_type;

typedef struct 
{
	int dimemsions;
	//dimensions store how many dimensions in total
	int dimemsion_list[256];
	//dimension_list store each dimension's length, assuming not exceed 256 dimensions
} array_type;

typedef struct 
{
	basic_type basic;
	array_type dimension;
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

typedef struct ENTRY
{
	char name_column[33];
	kind kind_column;
	whole_type type_column;
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
void add_id(entry e);
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
