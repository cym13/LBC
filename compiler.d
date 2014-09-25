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

void program(string label)
{
    block("");
    if (LOOK != 'e')
        expected("End");
    emitln("END");
}

void condition()
{
    emitln("<condition>");
}

void doIf(string label)
{
    match('i');

    condition();

    string label1 = newLabel();
    string label2 = label1;
    emitln("BEQ " ~ label1);
    block(label);

    if (LOOK == 'l') {
        match('l');
        label2 = newLabel();
        emitln("BRA " ~ label2);
        postLabel(label1);
        block(label);
    }

    match('e');
    postLabel(label2);
}

void doWhile()
{
    match('w');
    string label1      = newLabel();
    string label2      = newLabel();
    string break_label = newLabel();
    postLabel(label1);

    condition();
    emitln("BEQ " ~ label2);

    block(break_label);
    match('e');
    emitln("BRA " ~ label1);
    postLabel(label2);
}

void doRepeat()
{
    string label       = newLabel();
    string break_label = newLabel();
    postLabel(label);

    block(break_label);

    match('u');
    condition();
    emitln("BEQ " ~ label);
}

void doLoop()
{
    string label       = newLabel();
    string break_label = newLabel();
    postLabel(label);

    block(break_label);

    match('e');
    emitln("BRA " ~ label);
    postLabel(break_label);
}

void expression()
{
    emitln("<expr>");
}

void doFor()
{
    match('f');
    string name        = getName();
    string label1      = newLabel();
    string label2      = newLabel();
    string break_label = newLabel();

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

    block(break_label);

    match('e');
    emitln("BRA " ~ label1);
    postLabel(label2);
    emitln("ADDQ #2,SP");
}

void doDo()
{
    match('d');
    string label       = newLabel();
    string break_label = newLabel();

    expression();
    emitln("SUBQ #1,D0");

    postLabel(label);
    emitln("MOVE D0,-(SP)");

    block(break_label);

    emitln("MOVE (SP)+,D0");
    emitln("DBRA D0," ~ label);
    emitln("SUBQ #2,SP");
    postLabel(break_label);
    emitln("ADDQ #2,SP");
}

void doBreak(string label)
{
    match('b');
    if (label != "")
        emitln("BRA " ~ label);
    else
        abort("No loop to break from");
}

void block(string label)
{
    while (!canFind(['e', 'l', 'u'], LOOK)) {
        switch (LOOK) {
            case 'i': doIf(label);
                      break;
            case 'w': doWhile();
                      break;
            case 'p': doLoop();
                      break;
            case 'r': doRepeat();
                      break;
            case 'f': doFor();
                      break;
            case 'd': doFor();
                      break;
            case 'b': doBreak(label);
                      break;
            default : other();
        }
    }
}

/********************************************************/

bool isBoolean(char c) {
    return canFind(['T', 'F'], c.toUpper());
}

bool getBoolean() {
    bool b;
    if (!isBoolean(LOOK))
        expected("Boolean Literal");

    b = LOOK.toUpper() == 'T';
    getChar();
    return b;
}

void boolExpression() {
    boolTerm();
    while (isOrOp(LOOK)) {
        emitln("MOVE D0,-(SP)");
        switch (LOOK) {
            case '|': boolOr()  ; break;
            case '~': boolXor() ; break;
            default : break;
        }
    }
}

bool isOrOp(char c) {
    return canFind(['|', '~'], c);
}

void boolTerm() {
    notFactor();
    while (LOOK == '&') {
        emitln("MOVE D0,-(SP)");
        match('&');
        notFactor();
        emitln("AND (SP)+,D0");
    }
}

void notFactor() {
    if (LOOK == '!') {
        match('!');
        boolFactor();
        emitln("EOR #-1,D0");
    }
    else {
        boolFactor();
    }
}

void boolFactor() {
    if (isBoolean(LOOK)) {
        if (getBoolean())
            emitln("MOVE #-1,D0");
        else
            emitln("CLR D0");
    }

    else {
        relation();
    }
}

void relation() {
    expression();
    if (isRelOp(LOOK)) {
        emitln("MOVE D0,-(SP)");
        switch (LOOK){
            case '=': equals()    ; break;
            case '#': notEquals() ; break;
            case '<': less()      ; break;
            case '>': greater()   ; break;
            default :               break;
        }
        emitln("TST D0");
    }
}

void boolOr() {
    match('|');
    boolTerm();
    emitln("OR (SP)+,D0");
}

void boolXor() {
    match('~');
    boolTerm();
    emitln("EOR (SP)+,D0");
}

bool isRelOp(char c) {
    return canFind(['=', '#', '<', '>'], c);
}

void equals() {
    match('=');
    expression();
    emitln("CMP (SP)+,D0");
    emitln("SEQ D0");
}

void notEquals() {
    match('#');
    expression();
    emitln("CMP (SP)+,D0");
    emitln("SNE D0");
}

void less() {
    match('<');
    expression();
    emitln("CMP (SP)+,D0");
    emitln("SGE D0");
}

void greater() {
    match('>');
    expression();
    emitln("CMP (SP)+,D0");
    emitln("SLE D0");
}
/********************************************************/

int main() {
    getChar();
    skipWhite();

    program("");
    return 0;
}
