#include <iostream>
#include "tree.h"

Tree::Tree(){}

Tree::Tree(std::string value_g, int type_g)
{
    this->value = value_g;
    this->type = type_g;
}

Tree::~Tree(){}


std::string Tree::getToken()
{
    return this->value;
}


std::vector<Tree *> Tree::getChild()
{
    return this->child;
}


void Tree::addChild(Tree *obj)
{
    child.push_back(obj);
}


int Tree::getType()
{
    return this->type;
}
