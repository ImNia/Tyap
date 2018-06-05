#pragma once
#include <iostream>
#include <vector>
#include <string>

enum types {
    ASSIGN, // =
    MATH, // +-/*
    INT, // token int (int foo)
    DOUBLE, // token double
    ID, // variable
    CONST, // some const (f.e. 2)
    IF, // token if
    ELSE, // token else
    WHILE, // token while
    PRINT, // token print
    SCAN // token write
};

class Tree
{
	public:
		Tree();
        Tree(std::string value_g, int type_g);
		~Tree();
        std::string getToken();
        std::vector<Tree *> getChild();
        void addChild(Tree *obj);

    private:
		std::string value;
		std::vector<Tree *>child;        
        int type;
};
