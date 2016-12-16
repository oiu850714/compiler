#makefile for parser
LEX = lex
YACC = yacc
LEXFN = lex.l
YACCFN = parser.y
CC = gcc
CFLAGS = -O2
LIBS = -lfl -lbsd -ly
RM = rm -f
PARSERRN = parser
SCANNERSN = lex.yy.c
PARSERSN = y.tab.c
INTERFACE = y.tab.h
YACCVERBOSE = y.output
TESTFN = whole.cm
all: parser

parser: yacc lex
	$(CC) -o $(PARSERRN) $(SCANNERSN) $(PARSERSN) $(LIBS)
yacc:
	$(YACC) -v -d $(YACCFN) 
lex:
	$(LEX) $(LEXFN)
clean:
	$(RM) $(SCANNERSN)
	$(RM) $(PARSERSN)
	$(RM) $(PARSERRN)
	$(RM) $(INTERFACE)
	$(RM) $(YACCVERBOSE)

	

