#!/usr/bin/env rdmd

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

import std.stdio;
import std.ascii;
import std.c.process;
import std.conv;
import utils;

int[string] TABLE;

int getNum()
{
    string value = "";
    string retval;

    if (!isDigit(LOOK))
        expected("Integer");

    while (isDigit(LOOK)) {
        value ~= LOOK;
        getChar();
    }

    retval = value;
    skipWhite();
    return to!int(value);
}


void initTable()
{
    foreach(char c; uppercase) {
        TABLE[to!string(c)] = 0;
    }
}

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
