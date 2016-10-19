%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<%s>\n", #t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
char buf[MAX_LINE_LENGTH];

struct node
{
    int frequency;
    char id[257];
    struct node *next;
};

struct node *head = NULL;

%}

digit	[0-9]
letter_  [_a-zA-Z]
floating_point {digit}+\.{digit}+
scientific {floating_point}[Ee][+-]?{digit}+
string \"(\\.|[^"\\\xA]|\\\xA)*\"
cpp_comment "//"
c_comment_first "/*"
c_comment_second "*/"
any_char .*

comment {c_comment_first}([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*{c_comment_second}

%%

\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}

{cpp_comment}{any_char} {
    LIST;
}

{comment} {
    char *p = yytext;
    int i = 0;
    int j = strlen(buf);
    for( ; i < strlen(yytext); i++)
    {
        if( *(p+i) == '\n' )
        {
            if(Opt_Source)
                printf("%d:%s\n", linenum, buf);
            ++linenum;
            buf[0] = '\0';
            j = 0;
        }
        else
        {
            buf[j] = *(p+i);
            buf[++j] = '\0';
            // j will increment only if there is a new not-newline character to put in buf
        }
    }
}


"#pragma source on" {
    LIST;
    Opt_Source = 1;
}

"#pragma source off" {
    LIST;
    Opt_Source = 0;
}

"#pragma token on" {
    LIST;
    Opt_Token = 1;
}

"#pragma token off" {
    LIST;
    Opt_Token = 0;
}

"#pragma statistic on" {
    LIST;
    Opt_Statistic = 1;
}

"#pragma statistic off" {
    LIST;
    Opt_Statistic = 0;
}

"(" {
    tokenString("delim", "("); 
}

")" {
    tokenString("delim", ")");
}

"{" {
    tokenString("delim", "{");
}

"}" {
    tokenString("delim", "}");
}

"[" {
    tokenString("delim", "[");
}

"]" {
    tokenString("delim", "]");
}

"," {
    tokenString("delim", ",");
}

";" {
    tokenString("delim", ";");
}


"+" {
    token("+");
}

"-" {
    token("-");
}

"*" {
    token("*");
}

"/" {
    token("/");
}

"%" {
    token("%");
}

"<=" {
    token("<=");
}

">=" {
    token(">=");
}

"==" {
    token("==");
}

"!=" {
    token("!=");
}

"<" {
    token("<");
}

">" {
    token(">");
}

"=" {
    token("=");
}

"&&" {
    token("&&");
}

"\|\|" {
    token("\|\|");
}

"!" {
    token("!");
}



"while" {
   tokenString("KW", "while");
}

"do" {
   tokenString("KW", "do");
}

"if" {
   tokenString("KW", "if");
}

"else" {
   tokenString("KW", "else");
}

"true" {
   tokenString("KW", "true");
}

"false" {
   tokenString("KW", "false");
}

"for" {
   tokenString("KW", "for");
}

"int" {
   tokenString("KW", "int");
}

"print" {
   tokenString("KW", "print");
}

"const" {
   tokenString("KW", "const");
}

"read" {
   tokenString("KW", "read");
}

"boolean" {
   tokenString("KW", "boolean");
}

"bool" {
   tokenString("KW", "bool");
}

"void" {
   tokenString("KW", "void");
}

"float" {
   tokenString("KW", "float");
}

"double" {
   tokenString("KW", "double");
}

"string" {
   tokenString("KW", "string");
}

"continue" {
   tokenString("KW", "continue");
}

"break" {
   tokenString("KW", "break");
}

"return" {
   tokenString("KW", "return");
}

{letter_}({letter_}|{digit})* {

   struct node *current = head;
   if(head == NULL)
   {
      head = (struct node*)malloc(sizeof(struct node));
      head->frequency = 1;
      strcpy(head->id, yytext);
      head->next = NULL;
      // this is fucking shit since yytext is bigger than id,
      //but HW's spec says id will not exceed 256 bytes.
   }
   else
   {
      while(current)
      {
          if(strcmp(current->id, yytext) == 0)
          {
              current->frequency += 1;
              break;
          }
          else if(current->next == NULL)
          {
              current->next = (struct node*)malloc(sizeof(struct node));
              current->next->frequency = 1;
              strcpy(current->next->id, yytext);
              //fucking shit too, my life is fucking shit too.
              current->next->next = NULL;
              // current->next->next yeah
              break;
          }
          else
             current = current->next;
      }
   }
   
   tokenString("id", yytext);
}

([0])|([1-9]({digit}*)) {
   tokenString("integer", yytext);
}

{floating_point} {
   tokenString("float", yytext); 
}

{scientific} {
   tokenString("scientific", yytext);
}

{string} {
   LIST;
   if(Opt_Token)
   {
      int i = 1;
      printf("<string:");
      for(; i < strlen(yytext) - 1; ++i)
      // condition trick which doesn't print first and last double quote in yytext
         printf("%c", *(yytext+i));
      printf(">\n");
   }
}

[\t ] LIST;

. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}

%%

int main( int argc, char **argv )
{
    if (argc >= 2)
    {
        yyin = fopen( argv[1], "r" );
        if ( NULL == yyin ) {
            fprintf( stderr, "Cannot open: %s\n", argv[1] );
            exit(-1);
        }
    }
    else
    {
        yyin = stdin;
    }

    yylex();

    if (Opt_Statistic)
    {
        printf("frequencies of identifiers:\n");
        struct node *cur = head;
        while(cur)
        {
            printf("%s\t%d\n", cur->id, cur->frequency);
            struct node* del = cur;
            cur = cur->next;
            free(del);
        }
        // Print frequency table
    }

    exit(0);
}
