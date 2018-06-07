CC = g++

all: test

test: bison lex tree
	$(CC) -o tree lex.yy.c y.tab.c tree.o

bison: 
	bison -dy bison.y

lex: 
	flex lex.l
tree:
	$(CC) -c tree.cpp

clean:
	rm -rf *.o test
