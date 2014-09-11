#!/usr/bin/env rdmd

import std.stdio;
import std.ascii;
import std.c.process;

/******** GLOBAL VARIABLES ********/
char LOOK;
/**********************************/

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

