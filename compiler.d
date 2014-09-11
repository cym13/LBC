#!/usr/bin/env rdmd

import std.conv;
import std.stdio;
import std.ascii;
import std.c.process;
import std.algorithm;

import utils;
import arithmetics;

/******** GLOBAL VARIABLES ********/
int  LCOUNT = 0;
/**********************************/


string newLabel()
{
    return "L" ~ to!string(LCOUNT++);
}

void postLabel(string label)
{
    writeln(label ~ ":");
}

void other()
{
    emitln(getName());
}

void program()
{
    block();
    if (LOOK != 'e')
        expected("End");
    emitln("END");
}

void condition()
{
    emitln("<condition>");
}

void doIf()
{
    match('i');

    condition();

    string label1 = newLabel();
    string label2 = label1;
    emitln("BEQ " ~ label1);
    block();

    if (LOOK == 'l') {
        match('l');
        label2 = newLabel();
        emitln("BRA " ~ label2);
        postLabel(label1);
        block();
    }

    match('e');
    postLabel(label2);
}

void doWhile()
{
    match('w');
    string label1 = newLabel();
    string label2 = newLabel();
    postLabel(label1);

    condition();
    emitln("BEQ " ~ label2);

    block();
    match('e');
    emitln("BRA " ~ label1);
    postLabel(label2);
}

void doRepeat()
{
    string label = newLabel();
    postLabel(label);

    block();

    match('u');
    condition();
    emitln("BEQ " ~ label);
}

void doLoop()
{
    string label = newLabel();
    postLabel(label);

    block();

    match('e');
    emitln("BRA " ~ label);
}

void expression()
{
    emitln("<expr>");
}

void doFor()
{
    match('f');
    string label1 = newLabel();
    string label2 = newLabel();
    string name   = getName();

    match('=');
    expression();
    emitln("MOVE D0,-(SP)");

    postLabel(label1);
    emitln("LEA " ~ name ~ "(PC),A0");
    emitln("MOVE (A0),D0");
    emitln("ADDQ #1,D0");
    emitln("MOVE D0,(A0)");
    emitln("CMP (SP),D0");
    emitln("BGT " ~ label2);

    block();

    match('e');
    emitln("BRA " ~ label1);
    postLabel(label2);
    emitln("ADDQ #2,SP");
}

void block()
{
    while (!canFind(['e', 'l', 'u'], LOOK)) {
        switch (LOOK) {
            case 'i': doIf();
                      break;
            case 'w': doWhile();
                      break;
            case 'p': doLoop();
                      break;
            case 'r': doRepeat();
                      break;
            case 'f': doFor();
                      break;
            default : other();
        }
    }
}

int main() {
    getChar();
    skipWhite();

    program();
    return 0;
}
