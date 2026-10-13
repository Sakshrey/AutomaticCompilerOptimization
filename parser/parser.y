%code requires
{
typedef struct ASTNode ASTNode;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast/ast.h"
#include "ir/ir.h"
#include "optimizer/constant_folding.h"
#include "optimizer/algebraic_simplification.h"
#include "optimizer/dead_code_elimination.h"
#include "optimizer/common_subexpression.h"
#include "optimizer/pass_manager.h"

int yylex();
void yyerror(const char *s);

ASTNode *root;
%}

%union
{
    ASTNode *node;
    char *text;
}

%token INT RETURN
%token <text> ID NUMBER
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN SEMICOLON

%type <node> program statements statement declaration assignment return_statement expression term factor

%%

program:
    statements
    {
        root = $1;
    }
    ;

statements:
    statements statement
    {
        $$ = createNode("Statements", "", $1, $2);
    }
    | statement
    {
        $$ = $1;
    }
    ;

statement:
    declaration
    {
        $$ = $1;
    }
    | assignment
    {
        $$ = $1;
    }
    | return_statement
    {
        $$ = $1;
    }
    ;

declaration:
    INT ID SEMICOLON
    {
        $$ = createNode("Declaration", $2, NULL, NULL);
    }
    | INT ID ASSIGN expression SEMICOLON
    {
        ASTNode *id = createNode("Identifier", $2, NULL, NULL);
        $$ = createNode("Declaration", "", id, $4);
    }
    ;

assignment:
    ID ASSIGN expression SEMICOLON
    {
        ASTNode *id = createNode("Identifier", $1, NULL, NULL);
        $$ = createNode("Assignment", "", id, $3);
    }
    ;

return_statement:
    RETURN expression SEMICOLON
    {
        $$ = createNode("Return", "", $2, NULL);
    }
    ;

expression:
    expression PLUS term
    {
        $$ = createNode("Operator", "+", $1, $3);
    }
    | expression MINUS term
    {
        $$ = createNode("Operator", "-", $1, $3);
    }
    | term
    {
        $$ = $1;
    }
    ;

term:
    term MULTIPLY factor
    {
        $$ = createNode("Operator", "*", $1, $3);
    }
    | term DIVIDE factor
    {
        $$ = createNode("Operator", "/", $1, $3);
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor:
    NUMBER
    {
        $$ = createNode("Number", $1, NULL, NULL);
    }
    | ID
    {
        $$ = createNode("Identifier", $1, NULL, NULL);
    }
    | LPAREN expression RPAREN
    {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s)
{
    printf("Invalid syntax\n");
}

int main()
{
    printf("Enter program:\n");

    if(yyparse() == 0)
    {
        printf("\nAST:\n");
        printAST(root, 0);

        generateIR(root);

        printf("\nBefore Optimization:\n");
        printIR();

        runPass("CF");

        printf("\nAfter Constant Folding:\n");
        printIR();

        runPass("AS");

        printf("\nAfter Algebraic Simplification:\n");
        printIR();

        runPass("DCE");

        printf("\nAfter Dead Code Elimination:\n");
        printIR();

        runPass("CSE");

        printf("\nAfter Common Subexpression Elimination:\n");
        printIR();
    }

    return 0;
}