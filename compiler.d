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
    if (LOOK == c)
        getChar();
}

bool isAddop(char c)
{
    return LOOK == '+' || LOOK == '-';
}

bool isMulop(char c)
{
    return LOOK == '*' || LOOK == '/';
}

char getName()
{
    if (!isAlpha(LOOK))
        expected("Name");

    char result = LOOK;
    getChar();
    return result.toUpper();
}

char getNum()
{
    if (!isDigit(LOOK))
        expected("Integer");

    char result = LOOK;
    getChar();
    return result;
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

void add()
{
    match('+');
    term();
    emitln("ADD (SP)+,D0");
}

void substract()
{
    match('-');
    term();
    emitln("SUB (SP)+,D0");
    emitln("NEG D0");
}

void multiply()
{
    match('*');
    factor();
    emitln("MULS (SP)+,D0");
}

void divide()
{
    match('/');
    factor();
    emitln("MOVE (SP)+,D1");
    emitln("DIVS D1,D0");
}

void term()
{
    // factor
    factor();

    // mulop expression
    while (isMulop(LOOK)) {
        emitln("MOVE D0,-(SP)");
        switch (LOOK) {
            case '*': multiply(); break;
            case '/': divide();   break;
            default:  expected("Mulop");
        }
    }
}

void factor()
{
    // expression
    if (LOOK == '(') {
        match('(');
        expression();
        match(')');
    }

    // variable name
    else if (isAlpha(LOOK))
        ident();

    // number
    else
        emitln("MOVE #" ~ getNum() ~ ",D0");
}

void expression()
{
    // sign
    if (isAddop(LOOK))
        emitln("CLR D0");
    // term
    else
        term();

    // addop expression
    while (isAddop(LOOK)) {
        emitln("MOVE D0,-(SP)");
        switch (LOOK) {
            case '+': add();       break;
            case '-': substract(); break;
            default:  expected("Addop");
        }
    }
}

void ident()
{
    char name = getName();

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
    char name = getName();
    match('=');
    expression();
    emitln("LEA " ~ name ~ "(PC),A0");
    emitln("MOVE D0,(A0)");
}


int main() {
    getChar();
    expression();
    //assignment();
    if (LOOK != '\n')
        expected("Newline");

    return 0;
}
