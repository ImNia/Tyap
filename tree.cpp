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

int main()
{
    Tree *child_a = new Tree("a", 1);
    Tree *child_2 = new Tree("2", 1);
    Tree *parent = new Tree("=", 1);

    parent->addChild(child_a);
    parent->addChild(child_2);

    return 0;
}
