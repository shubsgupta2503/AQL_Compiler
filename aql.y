%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct TreeNode {
    char* text;
    struct TreeNode **subnodes;
    int num_children;
} TreeNode;

TreeNode* make_node(char* label);
void attach_child(TreeNode* parent, TreeNode* child);
void display_tree(TreeNode* node, int depth);

int yylex();
void yyerror(const char *msg);
%}

%union {
    char* sval;
    struct TreeNode* node;
}

%left OR
%left AND

%token <sval> SELECT FROM CONTAINS WHERE AND OR EHR COMPOSITION IDENTIFIER STRING
%token <sval> EQUALS SLASH
%token <sval> '(' ')'
%token <sval> '[' ']'

%type <node> query_clause where_block expr

%%

query_clause:
    SELECT IDENTIFIER FROM EHR IDENTIFIER CONTAINS COMPOSITION IDENTIFIER '[' IDENTIFIER ']' where_block {
        TreeNode* root = make_node("QueryRoot");
        attach_child(root, make_node("SELECT"));
        attach_child(root, make_node($2));
        attach_child(root, make_node("FROM"));
        attach_child(root, make_node("EHR"));
        attach_child(root, make_node($5));
        attach_child(root, make_node("CONTAINS"));
        attach_child(root, make_node("COMPOSITION"));
        attach_child(root, make_node($8));
        TreeNode* bracketGroup = make_node("Brackets");
        attach_child(bracketGroup, make_node($10));
        attach_child(root, bracketGroup);
        if ($12) attach_child(root, $12);

        printf("AQL query parsed.\nParse Tree:\n");
        display_tree(root, 1);
    }
    ;

where_block:
      /* no where clause */ { $$ = NULL; }
    | WHERE expr {
        TreeNode* whereNode = make_node("WHERE");
        attach_child(whereNode, $2);
        $$ = whereNode;
    }
    ;

expr:
      expr AND expr {
        TreeNode* andNode = make_node("AND");
        attach_child(andNode, $1);
        attach_child(andNode, $3);
        $$ = andNode;
      }
    | expr OR expr {
        TreeNode* orNode = make_node("OR");
        attach_child(orNode, $1);
        attach_child(orNode, $3);
        $$ = orNode;
      }
    | '(' expr ')' {
        $$ = $2;
      }
    | IDENTIFIER SLASH IDENTIFIER EQUALS STRING {
        TreeNode* cond = make_node("Condition");
        attach_child(cond, make_node($1));
        attach_child(cond, make_node("/"));
        attach_child(cond, make_node($3));
        attach_child(cond, make_node("="));
        attach_child(cond, make_node($5));
        $$ = cond;
      }
    ;

%%

TreeNode* make_node(char* label) {
    TreeNode* n = (TreeNode*)malloc(sizeof(TreeNode));
    n->text = strdup(label);
    n->subnodes = NULL;
    n->num_children = 0;
    return n;
}

void attach_child(TreeNode* parent, TreeNode* child) {
    parent->subnodes = realloc(parent->subnodes, sizeof(TreeNode*) * (parent->num_children + 1));
    parent->subnodes[parent->num_children++] = child;
}

void display_tree(TreeNode* node, int depth) {
    for (int i = 0; i < depth - 1; i++) printf("│   ");
    printf("├── [%d] %s\n", depth, node->text);
    for (int i = 0; i < node->num_children; i++) {
        display_tree(node->subnodes[i], depth + 1);
    }
}

int main() {
    return yyparse();
}

void yyerror(const char *msg) {
    fprintf(stderr, "Syntax error: %s\n", msg);
}
