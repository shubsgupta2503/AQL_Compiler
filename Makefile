all:
	bison -d aql.y
	flex aql.l
	gcc aql.tab.c lex.yy.c -o aql -lfl