%{
#include <stdio.h>
#include <string.h>
#include "aql.tab.h"
%}

%%

"SELECT"                { yylval.sval = strdup(yytext); return SELECT; }
"FROM"                  { yylval.sval = strdup(yytext); return FROM; }
"EHR"                   { yylval.sval = strdup(yytext); return EHR; }
"CONTAINS"              { yylval.sval = strdup(yytext); return CONTAINS; }
"COMPOSITION"           { yylval.sval = strdup(yytext); return COMPOSITION; }
"WHERE"                 { yylval.sval = strdup(yytext); return WHERE; }
"AND"                   { yylval.sval = strdup(yytext); return AND; }
"OR"                    { yylval.sval = strdup(yytext); return OR; }

"="                     { yylval.sval = strdup("="); return EQUALS; }
"/"                     { yylval.sval = strdup("/"); return SLASH; }

"("                     { return '('; }
")"                     { return ')'; }
"["                     { return '['; }
"]"                     { return ']'; }

\"[^\"]*\"              { yylval.sval = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return IDENTIFIER; }

[ \t\n\r]+              { /* skip whitespace */ }

.                       { printf("Unexpected character: %s\n", yytext); return 0; }

%%