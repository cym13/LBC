#!/usr/bin/env rdmd

import std.stdio;
import std.ascii;
import std.c.process;
import std.conv;

/*  Syntax and specifications:
    --------------------------

   - 26 variables available (a..z)
   - Assignments: a=EXPRESSION
   - Output:      !EXPRESSION
   - Input:       ?NAME

    Where:
    EXPRESSION is a mathematical expressions composed of +-/*()
    NAME       is the name of a variable

    The instructions are delimited by new lines
    The program must end with a dot '.'
*/

char LOOK;
int[string] TABLE;

void initTable()
{
    foreach(char c; uppercase) {
        TABLE[to!string(c)] = 0;
    }
}

void getChar()
{
    readf("%c", &LOOK);
}

void error(string msg)
{
    stderr.write("Error: " ~ msg ~ '\n');
}

void abort(string msg)
{
    error(msg);
    exit(1);
}

void expected(string msg)
{
    abort(msg ~ " expected");
}

void match(char c)
{
    if (LOOK != c)
        expected("'" ~ c ~ "'");

    else {
        getChar();
        skipWhite();
    }
}

bool isAddop(char c)
{
    return LOOK == '+' || LOOK == '-';
}

bool isMulop(char c)
{
    return LOOK == '*' || LOOK == '/';
}

bool isAlNum(char c)
{
    return isAlpha(c) || isDigit(c);
}

string getName()
{
    string token = "";
    string retval;

    if (!isAlpha(LOOK))
        expected("Name");

    while (isAlNum(LOOK)) {
        token ~= LOOK.toUpper();
        getChar();
    }

    retval = token;
    skipWhite();
    return token;
}

int getNum()
{
    int value = 0;
    if (!isDigit(LOOK))
        expected("Integer");

    while (isDigit(LOOK)) {
        value = 10 * value + LOOK - '0';
        getChar();
    }
    return value;
}

void skipWhite()
{
    while (LOOK == ' ' || LOOK == '\t') {
        getChar();
    }
}

void emit(string msg)
{
    write("\t" ~ msg);
}

void emitln(string msg)
{
    emit(msg);
    writeln();
}

/*******************************************************/
int term()
{
    int value = factor();

    // mulop expression
    while (isMulop(LOOK)) {
        final switch (LOOK) {
            case '*':
                match('*');
                value *= factor();
                break;

            case '/':
                match('/');
                value /= factor();
                break;
        }
    }

    return value;
}

int factor()
{
    int value;

    // expression
    if (LOOK == '(') {
        match('(');
        value = expression();
        match(')');
    }

    // variable
    else if (isAlpha(LOOK))
        value = TABLE[getName()];

    // number
    else
        value = getNum();

    return value;
}

int expression()
{
    int value;

    if (isAddop(LOOK))
        value = 0;
    else
        value = term();

    while (isAddop(LOOK)) {
        final switch (LOOK) {
            case '+':
                match('+');
                value += term();
                break;

            case '-':
                match('-');
                value -= term();
                break;
        }
    }

    return value;
}

void input()
{
    match('?');
    TABLE[getName()] = readf(" %s");
}

void output()
{
    match('!');
    writeln(expression());
}

void assignment()
{
    string name = getName();
    match('=');
    TABLE[name] = expression();
}

void init()
{
    initTable();
    getChar();
    skipWhite();
}


int main() {
    init();
    //writeln(expression());

    while(LOOK != '.') {
        switch (LOOK) {
            case '?':
                input();
                break;

            case '!':
                output();
                break;

            default:
                assignment();
        }
        match('\n');
    }

    return 0;
}
