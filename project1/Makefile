
edit : lex.yy.o
	gcc lex.yy.c -lfl -o scanner

lex.yy.o : lex.yy.c
	gcc -c lex.yy.c

lex.yy.c : scanner.l
	lex scanner.l

clean :
	rm *.o 
