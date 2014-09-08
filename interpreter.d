#!/usr/bin/env rdmd

import std.stdio;
import std.ascii;
import std.c.process;
import std.conv;

char LOOK;
int[char] TABLE;

void initTable()
{
    foreach(char c; uppercase)
        TABLE[c] = 0;
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
    // expression
    if (LOOK == '(') {
        match('(');
        return expression();
        match(')');
    }

    // number
    else
        return getNum();
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

void ident()
{
    string name = getName();

    // function
    if (LOOK == '(') {
        match('(');
        match(')');
        emitln("BSR " ~ name);
    }
    // assignment
    else if (LOOK == '=') {
        match('=');
        expression();
        emitln("LEA " ~ name ~ "(PC),A0");
        emitln("MOVE D0,(A0)");
    }
    // variable
    else
        emitln("MOVE " ~ name ~ "(PC),D0");
}

void assignment()
{
    string name = getName();
    match('=');
    expression();
    emitln("LEA " ~ name ~ "(PC),A0");
    emitln("MOVE D0,(A0)");
}


int main() {
    initTable();
    getChar();
    skipWhite();

    writeln(expression());

    return 0;
}
