CC = g++
OBJDIR = ./obj

all: dir test

dir: ./obj

./obj:
	mkdir ./obj

test: $(OBJDIR)/y.tab.o $(OBJDIR)/lex.yy.o $(OBJDIR)/tree.o $(OBJDIR)/comp.o
	$(CC) -o test $(OBJDIR)/*.o

$(OBJDIR)/y.tab.o: bison.y
	bison -o $(OBJDIR)/y.tab.c bison.y -d
	$(CC) -c -g $(OBJDIR)/y.tab.c -o $(OBJDIR)/y.tab.o -I./

$(OBJDIR)/lex.yy.o: lex.l
	flex -o $(OBJDIR)/lex.yy.c lex.l
	$(CC) -c -g $(OBJDIR)/lex.yy.c -o $(OBJDIR)/lex.yy.o -I./

$(OBJDIR)/tree.o: tree.cpp
	$(CC) -c -g tree.cpp -o $(OBJDIR)/tree.o -I./
	
$(OBJDIR)/comp.o: compiler.cpp
	$(CC) -c -g compiler.cpp -o $(OBJDIR)/comp.o -I./

clean:
	rm -rf ./obj
	rm test
