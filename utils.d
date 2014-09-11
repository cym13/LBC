#!/usr/bin/env rdmd

import std.stdio;
import std.ascii;
import std.c.process;

char LOOK;

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

string getNum()
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

