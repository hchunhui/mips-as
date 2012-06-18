CC       = gcc -g -c 
LD	 = gcc
LEX      = flex -i -I 
YACC     = bison -d -y -r all --debug

OBJ	 = asm.tab.o asm.lex.o

%.o : %.c
	$(CC) -o $@ $<
%.lex.c : %.lex
	$(LEX) -o $@ $<
%.tab.c : %.y
	$(YACC) -b asm -o $@ $<
as: $(OBJ)
	$(LD) -o $@ $(OBJ)
all: clean as
clean:
	rm -f $(OBJ)
	rm -f as
	rm -f *.output
