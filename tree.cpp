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

Hash::Hash()
{
    this->level = -1;
    this->addHash();
}

Hash::~Hash(){}


void Hash::addHash()
{
    this->level++;
    std::unordered_map<std::string, int>name;
    table.push_back(name);
}


void Hash::addElement(std::string one)
{
    table.back().insert({one, this->level});
}

void Hash::deleteHash()
{
    table.pop_back();
    this->level--;
}

int Hash::findElement(std::string one)
{
    for(int i = 0; i <= level; i++){
        if(table[i].find(one) != table[i].end())
            return 0;                   
    }
    return -1;
}
