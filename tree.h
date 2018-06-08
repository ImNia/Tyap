#pragma once
#include <iostream>
#include <vector>
#include <string>

enum types {
    _ASSIGN, // =
    _MATH, // +-/*
    _INT, // token int (int foo)
    _DOUBLE, // token double
    _ID, // variable
    _CONST, // some const (f.e. 2)
    _IF, // token if
    _ELSE, // token else
    _WHILE, // token while
    _PRINT, // token print
    _SCAN // token write
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
