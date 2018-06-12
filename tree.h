#pragma once
#include <iostream>
#include <vector>
#include <string>

#include <unordered_map>

enum types {
    _ROOT,
    _ASSIGN, // =
    _MATH, // +-/*
    _INT, // token int (int foo)
    _DOUBLE, // token double
    _ID, // variable
    _NUM, // some const (f.e. 2)
    _IF, // token if
    _IFELSE, // token if-else
    _WHILE, // token while
    _PRINT, // token print
    _SCAN, // token write
    _COMP // comparison
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
        int getType();

    private:
		std::string value;
		std::vector<Tree *>child;        
        int type;
};

class Hash
{
    public:
        Hash();
        ~Hash();
        void addHash();
        void addElement(std::string one);
        void deleteHash();
        int findElement(std::string one);

    private:
        std::vector<std::unordered_map<std::string, int>>table;
        int level;
};
