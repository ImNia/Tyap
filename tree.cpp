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
/*
int main()
{
    //int a = 2 + 2 * 2;
    Tree *a = new Tree("a", 1);
    Tree *two_1 = new Tree("2", 1);
    Tree *two_2 = new Tree("2", 1);
    Tree *two_3 = new Tree("2", 1);
    Tree *mul = new Tree("*", 1);
    Tree *sum = new Tree("+", 1);
    Tree *parent = new Tree("=", 1);
    Tree *type_int = new Tree("int", 1);

    sum->addChild(two_1);
    sum->addChild(two_2);

    mul->addChild(sum);
    mul->addChild(two_3);

    type_int->addChild(a);

    parent->addChild(type_int);
    parent->addChild(mul);

    return 0;
}
*/
