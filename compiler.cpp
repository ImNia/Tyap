#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <unordered_map>
#include <cmath>
#include <stack>

#include "compiler.h"
#include "tree.h"

std::ofstream outputFile("./include/tmp.asm", 
        std::ios_base::out | std::ios_base::trunc);

Tree *ast;
std::vector<std::string> stack;
std::unordered_map<std::string, int> varTypes;
std::stack<std::string> condJumps;
int constCnt = 0;
int condCnt = 0;
int loopCnt = 0;

int makeTemplate()
{
    std::ifstream templateFile("./include/template.asm", std::ios_base::in);
    if (outputFile.bad() || templateFile.bad()) {
        std::cout << "Couldn't open template file or directory." << 
            "Folder include is exist?" << std::endl;
        return -1;
    }

    outputFile << templateFile.rdbuf();

    return 0;
}

int addConst(std::string varValue)
{
    auto pointPos = varValue.find(".");
    if (pointPos == std::string::npos)
        varValue += ".0";
    std::string constVar = "const" + std::to_string(constCnt);
    std::string toPush = constVar + " dq " + varValue + "\n";
    stack.push_back(toPush);
    return constCnt++;
}

void unarTranslator(Tree *currNode, int type)
{
    std::string currToken = currNode->getToken();
    auto leftChild = currNode->getChild()[0];
    auto rightChild = currNode->getChild()[1];
    int leftChildType = leftChild->getType();
    int rightChildType = rightChild->getType();
    if (leftChildType == _NUM) {
        int constPos = addConst(rightChild->getToken());
        outputFile << "\tfld[const" + std::to_string(constPos) + "]\n";
    }
    else if (leftChildType == _ID) {
        std::string varName = leftChild->getToken();
        int varType = varTypes[varName];
        if (varType == _INT)
            outputFile << "\tfldz\n"
                << "\tfiadd dword[" << varName << "]\n";
        else if (varType == _DOUBLE)
            outputFile << "\tfld[" << varName << "]\n";
    }
    else if (leftChildType == _MATH) {
        unarTranslator(leftChild, _DOUBLE);
        outputFile << "\tfld[doubletmp1]\n";
    }
    if (rightChildType == _NUM) {
        int constPos = addConst(rightChild->getToken());
        outputFile << "\tfld[const" + std::to_string(constPos) + "]\n";
    }
    else if (rightChildType == _ID) {
        std::string varName = rightChild->getToken();
        int varType = varTypes[varName];
        if (varType == _INT)
            outputFile << "\tfldz\n"
                << "\tfiadd dword[" << varName << "]\n";
        else if (varType == _DOUBLE)
            outputFile << "\tfld[" << varName << "]\n";
    }
    else if (rightChildType == _MATH) {
        unarTranslator(rightChild, _DOUBLE);
        outputFile << "\tfld[doubletmp1]\n";
    }
    std::string op = currNode->getToken();
    if (op == "+") 
        outputFile << "\tfaddp\n";
    else if (op == "-") 
        outputFile << "\tfsubp\n";
    else if (op == "*") 
        outputFile << "\tfmulp\n";
    else if (op == "/") 
        outputFile << "\tfdivp\n";
    if (type == _INT)
        outputFile << "\tfistp[doubletmp1]\n";
    else
        outputFile << "\tfstp[doubletmp1]\n";
}

void declTranslator(Tree *currNode)
{
    std::string currToken = currNode->getToken();
    std::string varToken = currNode->getChild()[0]->getToken();
    auto var = varTypes.find(varToken);
    if (var == varTypes.end()) {
        int type = 0;
        if (currToken == "double") {
            type = _DOUBLE;
            std::string toPush = varToken + " dq ?";
            stack.push_back(toPush);
        } else {
            type = _INT;
            std::string toPush = varToken + " dd ?";
            stack.push_back(toPush);
        }
        varTypes.insert({varToken, type});
    }
}

void loadVarCond(Tree *child)
{
    int childType = child->getType();
    std::string childVar = child->getToken();
    if (childType == _NUM) {
        int constPos = addConst(childVar);
        outputFile << "\tfld[const" << constPos << "]\n";
    }
    else if (childType == _ID) {
        int varType = varTypes[childVar];
        if (varType == _DOUBLE)
            outputFile << "\tfld[" << childVar << "]\n";
        else
            outputFile << "\tfldz\n"
                << "\tfiadd dword[" << childVar << "]\n";
    }
    else if (childType == _MATH) {
        unarTranslator(child, _DOUBLE);
        outputFile << "\tfld[doubletmp1]\n";
    }
}

void nodeTranslator(Tree *currNode)
{
    std::string currToken = currNode->getToken();
    int currType = currNode->getType();
    if (currType == _ASSIGN) {
        auto *leftChild = currNode->getChild()[0];
        auto *rightChild = currNode->getChild()[1];
        int leftChildType = leftChild->getType();
        int rightChildType = rightChild->getType();

        std::string leftVarName;
        if (leftChildType == _INT || leftChildType == _DOUBLE) {
            declTranslator(leftChild);
            leftVarName = leftChild->getChild()[0]->getToken();
        } else {
            leftVarName = leftChild->getToken();
        }

        if (rightChildType == _ID) {
            std::string rightVarName = rightChild->getToken();
            int leftVarType = varTypes[leftVarName];
            int rightVarType = varTypes[rightVarName];
            if (leftVarType == _INT) {
                if (rightVarType == _DOUBLE)
                    outputFile << "\tfld[" << rightVarName << "]\n"
                        << "\tfistp [" << leftVarName << "]\n";
                else if (rightVarType == _INT)
                    outputFile << "\tmov eax,[" << rightVarName << "]\n"
                        << "\tmov [" << leftVarName << "], eax\n"
                        << "\txor eax,eax\n";
            } else if (leftVarType == _DOUBLE) {
                if (rightVarType == _DOUBLE) 
                    outputFile << "\tfld[" << rightVarName << "]\n"
                        << "\tfstp[" << leftVarName << "]\n";
                else if (rightVarType == _INT)
                    outputFile << "\tfldz\n"
                        << "\tfiadd dword[" << rightVarName << "]\n"
                        << "\tfstp[" << leftVarName << "]\n";
            }
        }
        else if (rightChildType == _NUM) {
            std::string rightConst = rightChild->getToken();
            int leftVarType = varTypes[leftVarName];
            auto pointPos = rightConst.find(".");
            if (leftVarType == _INT) {
                if (pointPos != std::string::npos)
                    rightConst = rightConst.substr(0, pointPos);
                outputFile << "\tmov [" + leftVarName + "]," + rightConst + "\n";
            } else {
                int constPos = addConst(rightConst);
                outputFile << "\tfld[const" + std::to_string(constPos) + "]\n"
                    << "\tfstp [" + leftVarName + "]\n";
            }
        }
        else if (rightChildType == _MATH) {
            int type = varTypes[leftVarName];
            unarTranslator(rightChild, type);
            if (type == _INT) 
                outputFile << "\tmov eax,dword[doubletmp1]\n"
                    << "\tmov [" << leftVarName << "],eax\n"
                    << "\txor eax,eax\n";
            else if (type == _DOUBLE)
                outputFile << "\tfld[doubletmp1]\n"
                    << "\tfstp[" << leftVarName << "]\n";
        }
    }

    else if (currType == _INT || currType == _DOUBLE) {
        declTranslator(currNode);
    }
    else if (currType == _PRINT || currType == _SCAN) {
        auto varToPrint = currNode->getChild()[0];
        auto varString = varToPrint->getToken();
        int varType = varTypes[varString];

        if (currType == _PRINT) {
            if (varType == _INT)
                outputFile << "\tcinvoke printf, format_i, dword[" 
                    << varString << "]\n";
            else
                outputFile << "\tfld[" << varString << "]\n\tfstp[doubletmp1]\n"
                    << "\tcinvoke printf, format_d, dword[doubletmp1],"
                    << "dword[doubletmp1+4]\n";
            outputFile << "\tcinvoke printf, new_line\n";
        } else {
            if (varType == _INT)
                outputFile << "\tcinvoke scanf, format_i, "
                    << varString << "\n";
            else
                outputFile << "\tcinvoke scanf, format_d, "
                    << varString << "\n";
        }
    }

    else if (currType == _IF || currType == _IFELSE) {
        currNode = currNode->getChild()[0];
        auto *leftChild = currNode->getChild()[0];
        auto *rightChild = currNode->getChild()[1];
        loadVarCond(leftChild);
        loadVarCond(rightChild);
        outputFile << "\tfcompp\n"
            << "\tfstsw ax\n"
            << "\tsahf\n";
        int elseFlg = 0;
        if (currType == _IFELSE)
            elseFlg = 1;
        std::string jmpName = "EndCond";
        if (elseFlg) {
            jmpName = "ElseCond";
        }

        jmpName += std::to_string(condCnt);

        std::string op = currNode->getToken();
        if (op == "==")
            outputFile << "\tjne " << jmpName << std::endl;
        else if (op == "!=")
            outputFile << "\tje " << jmpName << std::endl;
        else if (op == "<")
            outputFile << "\tjbe " << jmpName << std::endl;
        else if (op == ">")
            outputFile << "\tjae " << jmpName << std::endl;
        else if (op == "<=")
            outputFile << "\tjb " << jmpName << std::endl;
        else if (op == ">=")
            outputFile << "\tja " << jmpName << std::endl;
        if (!elseFlg) {
             condCnt++;
         }

        auto statements = currNode->getChild()[2];
        for (auto &i: statements->getChild())
            nodeTranslator(i);

        if (elseFlg) {
            outputFile << "\tjmp EndCond" << condCnt << std::endl;
            outputFile << "ElseCond" << condCnt << ":\n";
            auto statements = currNode->getChild()[3];
            for (auto &i: statements->getChild())
                nodeTranslator(i);
            outputFile << "EndCond" << condCnt << ":\n";
            condCnt++;
        } else
            outputFile << jmpName << ":" << std::endl;
    }
    else if (currType == _WHILE) {
        currNode = currNode->getChild()[0];
        outputFile << "Loop" << loopCnt << ":\n";
        auto *leftChild = currNode->getChild()[0];
        auto *rightChild = currNode->getChild()[1];
        loadVarCond(leftChild);
        loadVarCond(rightChild);
        outputFile << "\tfcompp\n"
            << "\tfstsw ax\n"
            << "\tsahf\n";
        std::string op = currNode->getToken();
        if (op == "==")
            outputFile << "\tjne EndLoop" << loopCnt << std::endl;
        else if (op == "!=")
            outputFile << "\tje EndLoop" << loopCnt << std::endl;
        else if (op == "<")
            outputFile << "\tjbe EndLoop" << loopCnt << std::endl;
        else if (op == ">")
            outputFile << "\tjae EndLoop" << loopCnt << std::endl;
        else if (op == "<=")
            outputFile << "\tjb EndLoop" << loopCnt << std::endl;
        else if (op == ">=")
            outputFile << "\tja EndLoop" << loopCnt << std::endl;

        auto statements = currNode->getChild()[2];
        for (auto &i: statements->getChild())
            nodeTranslator(i);
        outputFile << "jmp Loop" << loopCnt << std::endl;
        outputFile << "EndLoop" << loopCnt << ":\n";
        loopCnt++;
    }

    outputFile.flush();
}

int ASTvisiter()
{
    for (auto &i: ast->getChild()) {
        nodeTranslator(i);
    }
    
    outputFile << "\tcinvoke exit\n"
        << "\nsegment readable writeable\n"
        << "doubletmp1 dq ?\n"
        << "format_i db '%d',0\n"
        << "format_d db '%lf',0\n"
        << "new_line db 0xA, 0\n";

    for (auto &i: stack)
        outputFile << i << std::endl;

    return 0;
}

int compile(Tree *tmp)
{
    ast = tmp;
    int rc = 0;
    rc = makeTemplate();
    if (rc)
        return -1;
    rc = ASTvisiter();
    return 0;
}
